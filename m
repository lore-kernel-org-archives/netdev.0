From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 00:25:44 -0700 (PDT)
Message-ID: <20100929.002544.183044247.davem@davemloft.net>
References: <20100928.214132.226782961.davem@davemloft.net>
	<20100928.223850.104051485.davem@davemloft.net>
	<1285742848.22570.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751849Ab0I2HZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:25:24 -0400
In-Reply-To: <1285742848.22570.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Sep 2010 08:47:28 +0200

> Still, this does not solve the problem for people wanting to disable
> ipv6 module load or disable it ?
> 
> install ipv6 /bin/true
> 
> or
> 
> options ipv6 disable=1

If you set the disable option, it should do the right thing.  Since
the ipv6 symbols will be available, yet the ipv6 stack won't by
default bring up ipv6 addresses onto interfaces etc.
