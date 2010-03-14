From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool.h: Add "structs are public" disclaimer comment
Date: Sun, 14 Mar 2010 17:50:34 +0000
Message-ID: <1268589034.2664.68.camel@localhost>
References: <20100314014335.GA17208@serverengines.com>
	 <20100313.181145.211264593.davem@davemloft.net>
	 <1268583478.30289.94.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ajitk@serverengines.com,
	ajitkhaparde@gmail.com, jeff@garzik.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9916 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728Ab0CNRuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Mar 2010 13:50:39 -0400
In-Reply-To: <1268583478.30289.94.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-03-14 at 09:17 -0700, Joe Perches wrote:
> On Sat, 2010-03-13 at 18:11 -0800, David Miller wrote:
> > For the millionth time, you cannot change these datastructures
> > like this without breaking all existing userspace applications
> > out there.
> 
> Maybe this might help reduce the broken record repetitiveness.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index b33f316..9bd7583 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -10,6 +10,15 @@
>   * Portions Copyright (C) Sun Microsystems 2008
>   */
>  
> +/*
> + * Do not submit patches that change the public structs not guarded by
> + * #ifdef __KERNEL__ in this file.
> + *
> + * In case the use of __u8, __u16, __u32 and other reserved types don't
> + * mean much to you, these structs are used by user-space applications
> + * and must not be changed.
> + */

This comment is not quite correct: reserved fields may be replaced so
long as the structure size and offsets of other fields stay the same.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

