From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next 0/3] Add support for IPv6 Segment Routing
Date: Fri, 14 Apr 2017 14:36:20 +0200
Message-ID: <20170414123623.28190-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:47482 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdDNMgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 08:36:24 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id B8AA967DF35
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 14:36:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support and documentation in iproute2 for
encapsulation with IPv6 SR, and for control of HMAC mappings.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

David Lebrun (3):
  ip: add ip sr command to control SR-IPv6 internal structures
  iproute: add support for SR-IPv6 lwtunnel encapsulation
  man: add documentation for IPv6 SR commands

 ip/Makefile            |   2 +-
 ip/ip.c                |   3 +-
 ip/ip_common.h         |   1 +
 ip/iproute.c           |   6 +-
 ip/iproute_lwtunnel.c  | 154 ++++++++++++++++++++++++++++++++
 ip/ipseg6.c            | 238 +++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-route.8.in |  39 +++++++-
 man/man8/ip-sr.8       |  58 ++++++++++++
 8 files changed, 495 insertions(+), 6 deletions(-)
 create mode 100644 ip/ipseg6.c
 create mode 100644 man/man8/ip-sr.8

-- 
2.10.2
