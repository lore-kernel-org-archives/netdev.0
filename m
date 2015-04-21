From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH 0/3] mpls: ABI changes for security and correctness
Date: Tue, 21 Apr 2015 21:34:24 +0100
Message-ID: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
References: <1429051503-31287-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:1982 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932164AbbDUUgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 16:36:43 -0400
In-Reply-To: <1429051503-31287-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/mpls/af_mpls.c                       | 132 ++++++++++++++++++++++++++++++-
 net/mpls/internal.h                      |   6 ++
 4 files changed, 148 insertions(+), 3 deletions(-)

-- 
2.1.4
