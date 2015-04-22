From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH v2 0/3] mpls: ABI changes for security and correctness
Date: Wed, 22 Apr 2015 11:14:36 +0100
Message-ID: <1429697679-13767-1-git-send-email-rshearma@brocade.com>
References: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:54406 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756404AbbDVKPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 06:15:09 -0400
In-Reply-To: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2:
 - don't treat loopback interfaces specially by enabling mpls by
   default

These changes make mpls not be enabled by default on all
interfaces when in use for security, along with ensuring that a label
not valid as an outgoing label can be added in mpls routes.

This series contains three ABI/behaviour-affecting changes which have
been split out from "[PATCH net-next v4 0/6] mpls: Behaviour-changing
improvements" without any further modification. These changes need to
be considered for 4.1 otherwise we'll be stuck with the current
behaviour/ABI forever.

Robert Shearman (3):
  mpls: Per-device MPLS state
  mpls: Per-device enabling of packet input
  mpls: Prevent use of implicit NULL label as outgoing label

 Documentation/networking/mpls-sysctl.txt |   9 +++
 include/linux/netdevice.h                |   4 +
 net/mpls/af_mpls.c                       | 125 ++++++++++++++++++++++++++++++-
 net/mpls/internal.h                      |   6 ++
 4 files changed, 141 insertions(+), 3 deletions(-)

-- 
2.1.4
