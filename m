From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/qlge: Use pr_<level>, shrink text
 a bit
Date: Wed, 21 Jul 2010 13:58:00 -0700 (PDT)
Message-ID: <20100721.135800.43444396.davem@davemloft.net>
References: <1279576149.5434.59.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34174
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750906Ab0GUU5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 16:57:44 -0400
In-Reply-To: <1279576149.5434.59.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 19 Jul 2010 14:49:08 -0700

> Add and use a few neatening macros
> Remove PFX
> Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> Convert printk(KERN_ERR to pr_err(
> 
> $ size drivers/net/qlge/built-in.o.*
>   text	   data	    bss	    dec	    hex	filename
>  116456	   2312	  25712	 144480	  23460	drivers/net/qlge/built-in.o.old
>  114909	   2312	  25728	 142949	  22e65	drivers/net/qlge/built-in.o.new
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
