From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH iproute2 net-next 0/2] ip: Allow TTL propagation to/from IP packets to be configured
Date: Mon, 10 Apr 2017 15:36:10 +0100
Message-ID: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>,
        Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:53318 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752760AbdDJOhB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:37:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for per-MPLS-lightweight-tunnel ttl
values and per route ttl-propagation for the purposes of MPLS to be
specified.

Robert Shearman (2):
  iproute: Add support for ttl-propagation attribute
  iproute: Add support for MPLS LWT ttl attribute

 ip/iproute.c           | 22 ++++++++++++++++++++++
 ip/iproute_lwtunnel.c  | 31 +++++++++++++++++++++++++++++--
 man/man8/ip-route.8.in | 19 +++++++++++++++++--
 3 files changed, 68 insertions(+), 4 deletions(-)

-- 
2.1.4
