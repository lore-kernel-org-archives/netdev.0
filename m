From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Convert printks to pr_<level>
Date: Sun, 11 Mar 2012 23:48:46 -0700 (PDT)
Message-ID: <20120311.234846.455580505379366792.davem@davemloft.net>
References: <1331526971.13200.9.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209Ab2CLGsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 02:48:51 -0400
In-Reply-To: <1331526971.13200.9.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sun, 11 Mar 2012 21:36:11 -0700

> Use a more current kernel messaging style.
> 
> Convert a printk block to print_hex_dump.
> Coalesce formats, align arguments.
> Use %s, __func__ instead of embedding function names.
> 
> Some messages that were prefixed with <foo>_close are
> now prefixed with <foo>_fini.  Some ah4 and esp messages
> are now not prefixed with "ip ".
> 
> The intent of this patch is to later add something like
>   #define pr_fmt(fmt) "IPv4: " fmt.
> to standardize the output messages.
> 
> Text size is trivially reduced. (x86-32 allyesconfig)
> 
> $ size net/ipv4/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
>  887888	  31558	 249696	1169142	 11d6f6	net/ipv4/built-in.o.new
>  887934	  31558	 249800	1169292	 11d78c	net/ipv4/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks a lot Joe.
