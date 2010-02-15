From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] niu.c: Use pr_<level>, netdev_<level> and
 netif_<level> macros
Date: Mon, 15 Feb 2010 00:30:09 -0800 (PST)
Message-ID: <20100215.003009.124053644.davem@davemloft.net>
References: <20100214.224108.51485961.davem@davemloft.net>
	<20100215.001319.150697350.davem@davemloft.net>
	<1266222199.16721.967.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33608
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753080Ab0BOI3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 03:29:54 -0500
In-Reply-To: <1266222199.16721.967.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 15 Feb 2010 00:23:19 -0800

> This creates a logging message without trailing \n
> if netif_msg_intr is false.

How so?  The first message in this function is keyed
off of 'intr' message debugging flag.
