From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 00:59:29 -0700 (PDT)
Message-ID: <20100929.005929.59676654.davem@davemloft.net>
References: <1285742848.22570.53.camel@edumazet-laptop>
	<20100929.002544.183044247.davem@davemloft.net>
	<1285746352.2615.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752621Ab0I2H7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:59:09 -0400
In-Reply-To: <1285746352.2615.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Sep 2010 09:45:52 +0200

> I must miss something obvious.
> 
> David, with your patch, I cant :
> 
> install ipv6 /bin/true
> modprobe ip_gre
> 
> FATAL: Error inserting ip_gre
> (/lib/modules/2.6.36-rc6-dirty/kernel/net/ipv4/ip_gre.ko): Unknown
> symbol in module, or unknown parameter (see dmesg)
> 
> [  223.150774] ip_gre: Unknown symbol icmpv6_send (err 0)
> 

Try the options disable=1, that works.

We already prevent the "/bin/true" stupidity from working in
the bonding driver, that's why we added the disable
module option to ipv6.
