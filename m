From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 00:26:36 -0700 (PDT)
Message-ID: <20100929.002636.39178116.davem@davemloft.net>
References: <20100929043642.GA3660@gondor.apana.org.au>
	<1285741443.22570.27.camel@edumazet-laptop>
	<20100929071158.GA4684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54377
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751849Ab0I2H0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:26:16 -0400
In-Reply-To: <20100929071158.GA4684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Sep 2010 16:11:58 +0900

> On Wed, Sep 29, 2010 at 08:24:03AM +0200, Eric Dumazet wrote:
> .
>> Well, sometimes people wants to :
>> 
>> /etc/modprobe.conf
>> install ipv6 /bin/true
>> 
>> 
>> Yet, be able to load ip_gre as a module
>> 
>> so IPV6=m, GRE=m,
> 
> I think if we cared about this we should provide ways to disable
> IPv6 (if there aren't any already) even when the module is loaded
> or the code is built-in.

We do provide this functionality already.
