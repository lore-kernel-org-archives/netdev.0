From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/5] mpls: Behaviour-changing improvements
Date: Thu, 19 Mar 2015 21:32:47 +0000
Message-ID: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33639 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbbCSVeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:34:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series consists of several small changes to make it easier to
understand the code, along with security and RFC-compliance
changes. These are important to consider before userspace begins
relying on the previous behaviour.

Robert Shearman (5):
  mpls: Use definition for reserved label checks
  mpls: Remove incorrect PHP comment
  mpls: Differentiate implicit-null and unlabeled neighbours
  mpls: Per-device enabling of packet forwarding
  mpls: Allow payload type to be associated with label routes

 Documentation/networking/mpls-sysctl.txt |   9 ++
 include/linux/netdevice.h                |   4 +
 net/mpls/af_mpls.c                       | 242 +++++++++++++++++++++++++------
 net/mpls/internal.h                      |   7 +
 4 files changed, 215 insertions(+), 47 deletions(-)

-- 
2.1.4
