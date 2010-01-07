From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per
 interface
Date: Thu, 07 Jan 2010 01:02:01 -0800 (PST)
Message-ID: <20100107.010201.51693251.davem@davemloft.net>
References: <4B44F895.9080205@gmail.com>
	<1262836445.29868.227.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danborkmann@googlemail.com, linux-kernel@vger.kernel.org,
	jmoyer@redhat.com, netdev@vger.kernel.org, netdev@oss.sgi.com
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47154
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932597Ab0AGJBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:01:54 -0500
In-Reply-To: <1262836445.29868.227.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Wed, 06 Jan 2010 21:54:05 -0600

> Please inline patches so they can be reviewed easily in reply.
> 
> 
> -       struct netpoll *np = npi->rx_np;
> +       struct netpoll **np = &npi->rx_np;
>  
> -       if (!np)
> +       if (!(*np))
> 
> This makes everything horrible. Can you avoid the double indirection?
> Using a list head might be a good answer.
> 

Agreed on all counts.
