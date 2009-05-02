From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c589_cs: add cis(firmware) of 3Com multifunction
 pcmcia card
Date: Fri, 01 May 2009 19:22:58 -0700 (PDT)
Message-ID: <20090501.192258.229612946.davem@davemloft.net>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090427215050.daeb45fd.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43324
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbZEBCXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 22:23:04 -0400
In-Reply-To: <20090427215050.daeb45fd.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Mon, 27 Apr 2009 21:50:50 +0900

> 
> 3c589_cs,3c574_cs,serial_cs:
> 
>  (1)add cis(firmware) of 3Com lan&modem mulitifunction pcmcia card.
>  (2)load correct configuration register for 3Com card
>  
>  
> Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

Applied to net-next-2.6.

But a few things to be mindful of next time, which I had to
clean up for you.

> + 	}
> +    	link->conf.ConfigBase = parse->config.base;
> +   	link->conf.Present = parse->config.rmask[0];

These three lines started with some spaces, then a tab
character.  It should just be one tab character.

GIT warns about this when applying patches so that such
spacing errors can be caught before code goes into the
tree.
