From: David Miller <davem@davemloft.net>
Subject: Re: errors in alignment changes..
Date: Wed, 10 Dec 2014 20:42:15 -0500 (EST)
Message-ID: <20141210.204215.46146677361631214.davem@davemloft.net>
References: <20141210.155203.1136471667049608187.davem@davemloft.net>
	<5488C447.5080906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitsuhiro.kimura.kc@renesas.com, netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932937AbaLKBmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 20:42:16 -0500
In-Reply-To: <5488C447.5080906@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 11 Dec 2014 01:08:07 +0300

>    I guess we can just do:
> 
> 		rxdesc->addr = dma_map_single(...);

Best not to leave a potentially invalid DMA address in a
receive descriptor the chip can potentially fetch and
look at.

That's why I said to put it into a local variable and
check for errors first.
