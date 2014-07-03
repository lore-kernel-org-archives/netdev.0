From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] defxx: Fix !DYNAMIC_BUFFERS compilation warnings
Date: Wed, 02 Jul 2014 18:26:52 -0700 (PDT)
Message-ID: <20140702.182652.692554807829883743.davem@davemloft.net>
References: <alpine.LFD.2.11.1406290146390.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaGCB0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:26:53 -0400
In-Reply-To: <alpine.LFD.2.11.1406290146390.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sun, 29 Jun 2014 02:09:19 +0100 (BST)

> This fixes compilation warnings:
> 
> drivers/net/fddi/defxx.c:294: warning: 'dfx_rcv_flush' declared inline after being called
> drivers/net/fddi/defxx.c:294: warning: previous declaration of 'dfx_rcv_flush' was here
> drivers/net/fddi/defxx.c:2854: warning: 'my_skb_align' defined but not used
> 
> triggered when the driver is built with DYNAMIC_BUFFERS undefined.  Code 
> tested to work just fine with these changes and a few DEFPA and DEFTA 
> boards.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Also applied, thanks.
