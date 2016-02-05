From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/2] mpls: packet stats and ttl propagation config
Date: Fri, 5 Feb 2016 19:27:50 +0000
Message-ID: <1454700472-13543-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:34651 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751711AbcBET21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 14:28:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements new bits of mpls functionality: keeping
statistics on packets as they pass through the box and allowing ttl
propagation to be configured.

Robert Shearman (2):
  mpls: packet stats
  mpls: allow TTL propagation to/from IP packets to be configured

 Documentation/networking/mpls-sysctl.txt |  19 +++
 include/net/netns/mpls.h                 |   4 +
 net/mpls/Makefile                        |   1 +
 net/mpls/af_mpls.c                       | 205 ++++++++++++++++++++++++-------
 net/mpls/internal.h                      |  93 +++++++++++++-
 net/mpls/mpls_iptunnel.c                 |  21 +++-
 net/mpls/proc.c                          | 128 +++++++++++++++++++
 7 files changed, 417 insertions(+), 54 deletions(-)
 create mode 100644 net/mpls/proc.c

-- 
2.1.4
