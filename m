From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 0/2] sh_eth: fix bugs in sh_eth_ring_init()
Date: Fri, 30 Oct 2015 00:50:47 +0300
Message-ID: <5844359.Wmo6777QiE@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:36762 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757232AbbJ2Vuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 17:50:51 -0400
Received: by lbjm5 with SMTP id m5so38322087lbj.3
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 14:50:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

   Here's a set of 2 patches against DaveM's 'net.git' repo which fix couple of
bugs in the sh_eth_ring_init() function.

[1/2] sh_eth: fix uninitialized arrays in sh_eth_ring_init()
[2/2] sh_eth: fix WARNING in dma_free_coherent()

MBR, Sergei
