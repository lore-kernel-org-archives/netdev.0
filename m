From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 v2] mii: Convert printks to netdev_info
Date: Thu, 03 Mar 2011 12:56:43 -0800 (PST)
Message-ID: <20110303.125643.116367883.davem@davemloft.net>
References: <1299184181.4338.152.camel@Joe-Laptop>
	<20110303.123225.242141985.davem@davemloft.net>
	<1299185190.4338.163.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47415
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932251Ab1CCU4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:56:06 -0500
In-Reply-To: <1299185190.4338.163.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 03 Mar 2011 12:46:30 -0800

> Add a bit more data to the output.
> Convert string speeds to integer.
> Object size reduced a tiny bit.
> $ size drivers/net/mii.o*
>    text	   data	    bss	    dec	    hex	filename
>    4155	     56	   1000	   5211	   145b	drivers/net/mii.o.new
>    4184	     56	   1000	   5240	   1478	drivers/net/mii.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.

> I believe I did this:
> 
> <edits drivers/net/mii.c>
> make drivers/net/mii.o
> git commit -s drivers/net/mii.c
> mv drivers/net/mii.o drivers/net/mii.o.new
> git checkout master -- drivers/net/mii.c
> make drivers/net/mii.o
> mv drivers/net/mii.o drivers/net/mii.i.old
> git checkout <branch> -- drivers/net/mii.c
> size drivers/net/mii.o.*
>  etc...
> git commit --amend drivers/net/mii.c (add etc...)
> 
> tun revert?  No mii change?  huh?

I think the definition of "last commit" used by --amend might be the
issue in this case.
