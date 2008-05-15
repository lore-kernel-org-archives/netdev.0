From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 1/1] /drivers/net/r6040.c: bad use of round_jiffies()
 ???
Date: Thu, 15 May 2008 14:43:13 -0700
Message-ID: <20080515144313.524d199d@infradead.org>
References: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "cj" <christophe.jaillet@wanadoo.fr>,
	"linux" <linux-kernel@vger.kernel.org>,
	<florian.fainelli@telecomint.eu>, <netdev@vger.kernel.org>
To: "Christophe Jaillet" <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38220 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755857AbYEOVnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 17:43:21 -0400
In-Reply-To: <20080515212624.D56371C00093@mwinf2723.orange.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008 23:26:22 +0200
"Christophe Jaillet" <christophe.jaillet@wanadoo.fr> wrote:

> From: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
> 
> Hi, here is a patch against linux/drivers/net/r6040.c.
> 
> Compared to other places in the kernel, I think that this driver
> misuses the function round_jiffies.
> 
> 
> Note: this patch is based on 'linux-2.6.25.tar.bz2'
> 
> Signed-off-by: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
> 
> ---
> 
> --- linux 2.6.25/drivers/net/r6040.c	2008-05-15
> 23:21:28.000000000 +0200 +++ linux
> 2.6.25/drivers/net/r6040.c.cj	2008-05-15 22:16:44.000000000
> +0200 @@ -733,7 +733,7 @@ static void r6040_timer(unsigned long da }
>  
>  	/* Timer active again */
> -	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));
> +	mod_timer(&lp->timer, round_jiffies(jiffies + HZ));
>  }
>  

good catch!
Acked-by: Arjan van de Ven <arjan@linux.intel.com>
