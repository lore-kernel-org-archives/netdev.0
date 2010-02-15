From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] niu.c: Use pr_<level>, netdev_<level> and
 netif_<level> macros
Date: Mon, 15 Feb 2010 00:40:53 -0800
Message-ID: <1266223253.16721.974.camel@Joe-Laptop.home>
References: <20100214.224108.51485961.davem@davemloft.net>
	 <20100215.001319.150697350.davem@davemloft.net>
	 <1266222199.16721.967.camel@Joe-Laptop.home>
	 <20100215.003009.124053644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1060 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186Ab0BOIkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 03:40:55 -0500
In-Reply-To: <20100215.003009.124053644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-15 at 00:30 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 15 Feb 2010 00:23:19 -0800
> 
> > This creates a logging message without trailing \n
> > if netif_msg_intr is false.
> 
> How so?  The first message in this function is keyed
> off of 'intr' message debugging flag.

Quite right.  I misread it.

It might be better to move/merge the two parts of
the message.

cheers, Joe

