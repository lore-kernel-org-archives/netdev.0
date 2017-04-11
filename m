From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH v2 iproute2 net-next 0/2] ip: Allow TTL propagation to/from IP packets to be configured
Date: Tue, 11 Apr 2017 09:37:19 +0100
Message-ID: <1491899841-1361-1-git-send-email-rshearma@brocade.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:52736 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753028AbdDKIho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 04:37:44 -0400
In-Reply-To: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for per-MPLS-lightweight-tunnel ttl
values and per route ttl-propagation for the purposes of MPLS to be
specified.

Changes in v2:
 - use matches instead of strcmp for enabled/disabled keywords to
   avoid excessive typing

Robert Shearman (2):
  iproute: Add support for ttl-propagation attribute
  iproute: Add support for MPLS LWT ttl attribute

 ip/iproute.c           | 22 ++++++++++++++++++++++
 ip/iproute_lwtunnel.c  | 31 +++++++++++++++++++++++++++++--
 man/man8/ip-route.8.in | 19 +++++++++++++++++--
 3 files changed, 68 insertions(+), 4 deletions(-)

-- 
2.1.4
