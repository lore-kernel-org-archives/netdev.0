From: David Miller <davem@davemloft.net>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Mon, 03 Aug 2009 12:15:12 -0700 (PDT)
Message-ID: <20090803.121512.75779533.davem@davemloft.net>
References: <20090729073523.GA4515@gondor.apana.org.au>
	<20090802.130704.133993421.davem@davemloft.net>
	<1249301157.2893.11.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mpm@selenic.com,
	netdev@vger.kernel.org, mcarlson@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32834
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754311AbZHCTPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 15:15:04 -0400
In-Reply-To: <1249301157.2893.11.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 03 Aug 2009 13:05:57 +0100

> On Sun, 2009-08-02 at 13:07 -0700, David Miller wrote:
>> My position has always been that such printk's are simply
>> not allowed.  (check archives if you don't believe me :-)
>>
>> The locking is going to get rediculious if we start having
>> to account for this.
> 
> I agree with that, but this does seem quite restrictive.  How can we be
> sure that none of the kernel functions used by a driver's TX path (e.g.
> kmalloc or DMA-mapping) will print debug or warning messages?  If such
> guarantees exist, they do not seem to be documented.

Indeed, that's a good counter-argument.

Ho hum... so someone show me how ugly the locking is going
to get :-)
