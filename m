From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/4] test_rhashtable: add test case for rhl table
Date: Mon, 18 Sep 2017 23:07:07 +0200
Message-ID: <20170918210711.10202-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51748 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750711AbdIRVGx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:06:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a test case for the rhlist interface.

While at it, cleanup current rhashtable test a bit and add a check
for max_size support.

 test_rhashtable.c |  293 +++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 270 insertions(+), 23 deletions(-)
