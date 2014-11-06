From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Convert SEQ_START_TOKEN/seq_printf to
 seq_puts
Date: Wed, 05 Nov 2014 22:05:19 -0500 (EST)
Message-ID: <20141105.220519.797628811929880243.davem@davemloft.net>
References: <1415144223.1508.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaKFDFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 22:05:21 -0500
In-Reply-To: <1415144223.1508.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 04 Nov 2014 15:37:03 -0800

> Using a single fixed string is smaller code size than using
> a format and many string arguments.
> 
> Reduces overall code size a little.
> 
> $ size net/ipv4/igmp.o* net/ipv6/mcast.o* net/ipv6/ip6_flowlabel.o*
>    text	   data	    bss	    dec	    hex	filename
>   34269	   7012	  14824	  56105	   db29	net/ipv4/igmp.o.new
>   34315	   7012	  14824	  56151	   db57	net/ipv4/igmp.o.old
>   30078	   7869	  13200	  51147	   c7cb	net/ipv6/mcast.o.new
>   30105	   7869	  13200	  51174	   c7e6	net/ipv6/mcast.o.old
>   11434	   3748	   8580	  23762	   5cd2	net/ipv6/ip6_flowlabel.o.new
>   11491	   3748	   8580	  23819	   5d0b	net/ipv6/ip6_flowlabel.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Ok, I'm fine with this, applied.

Thanks Joe.
