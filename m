From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next 0/2] Add support for seg6 l2encap mode
Date: Mon, 28 Aug 2017 20:05:23 +0100
Message-ID: <20170828190525.15655-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:38245 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751322AbdH1TE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:56 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id D9A9867DABD
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 21:04:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the new L2ENCAP mode for SRv6
encapsulations.

David Lebrun (2):
  iproute: add support for seg6 l2encap mode
  man: add documentation for seg6 l2encap mode

 ip/iproute_lwtunnel.c  | 39 ++++++++++++++++++++++++++++-----------
 man/man8/ip-route.8.in |  6 +++++-
 2 files changed, 33 insertions(+), 12 deletions(-)

-- 
2.10.2
