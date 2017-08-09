From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next v2 0/3] Add support for SRv6 local segment processing
Date: Wed, 9 Aug 2017 17:33:23 +0200
Message-ID: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51603 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752945AbdHIPdW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 11:33:22 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 7BD4367DEBB
        for <netdev@vger.kernel.org>; Wed,  9 Aug 2017 17:33:12 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support and documentation for the seg6local
lightweight tunnel, enabling to perform operations to SR-enabled packets
based on their active segment.

v2: use a table for action names

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

David Lebrun (3):
  iproute: add helper functions for SRH processing
  iproute: add support for SRv6 local segment processing
  man: add documentation for seg6local lwt

 ip/iproute.c           |   2 +-
 ip/iproute_lwtunnel.c  | 324 +++++++++++++++++++++++++++++++++++++++++--------
 man/man8/ip-route.8.in |  62 +++++++++-
 3 files changed, 338 insertions(+), 50 deletions(-)

-- 
2.10.2
