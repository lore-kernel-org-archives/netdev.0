From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/21] net/atm neatening cleanups
Date: Tue, 26 Jan 2010 21:15:14 -0800 (PST)
Message-ID: <20100126.211514.72742813.davem@davemloft.net>
References: <cover.1264541547.git.joe@perches.com>
	<20100126.205757.101473582.davem@davemloft.net>
	<1264569109.14552.3.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48396
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752621Ab0A0FPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 00:15:01 -0500
In-Reply-To: <1264569109.14552.3.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 26 Jan 2010 21:11:49 -0800

> On Tue, 2010-01-26 at 20:57 -0800, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Tue, 26 Jan 2010 13:39:59 -0800
>> > Miscellaneous cleanups to net/atm
>> All looks good.
> 
> Unfortunately, appearances aren't necessarily trustworthy.
> 5/21 is missing a close parenthesis.
> 
> +	print_hex_dump(KERN_DEBUG, "br2684: skb: ", DUMP_OFFSET,
> +	               16, 1, skb->data, min(NUM2PRINT, skb->len, true);
>  #endif
> 
> should be:
> 
> +	print_hex_dump(KERN_DEBUG, "br2684: skb: ", DUMP_OFFSET,
> +	               16, 1, skb->data, min(NUM2PRINT, skb->len), true);
>  #endif
> 
> Want an updated 5/21 or another patch?

I'll fix it up myself, thanks.
