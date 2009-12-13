From: David Miller <davem@davemloft.net>
Subject: Re: question about drivers/net/3c507.c
Date: Sun, 13 Dec 2009 02:40:16 -0800 (PST)
Message-ID: <20091213.024016.77044163.davem@davemloft.net>
References: <Pine.LNX.4.64.0912131119540.24267@ask.diku.dk>
	<Pine.LNX.4.64.0912131124100.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43664
	"HELO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752368AbZLMKkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 05:40:15 -0500
In-Reply-To: <Pine.LNX.4.64.0912131124100.24267@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Sun, 13 Dec 2009 11:25:02 +0100 (CET)

> The function __devinit cpmac_probe in the file drivers/net/3c507.c 
> contains the following code:
> 
>        memcpy_toio(lp->base+SA_OFFSET, dev->dev_addr,
>                   sizeof(dev->dev_addr));
>  
> Is it correct that the size of the pointer is what is wanted?

Same as the cpmac.c case, needs to be fixed.
