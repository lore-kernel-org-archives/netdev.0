From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: Re: [PATCH] Ensure IF_READY is unset when link is not ready
Date: Thu, 8 Mar 2007 11:01:07 +0900
Message-ID: <20070308110107.6a010895.mitch@linux.vnet.ibm.com>
References: <20070305175924.2f46446c.mitch@linux.vnet.ibm.com>
	<E1HP5rQ-0008RW-00@gondolin.me.apana.org.au>
	<20070307.155438.27784474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:64907 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750700AbXCHCBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 21:01:32 -0500
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l282HxcP160512
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 13:17:59 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2824oNA015694
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 13:04:51 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2821JT7014423
	for <netdev@vger.kernel.org>; Thu, 8 Mar 2007 13:01:20 +1100
In-Reply-To: <20070307.155438.27784474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Mar 2007 15:54:38 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 08 Mar 2007 10:47:56 +1100
> 
> > Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> > > 
> > > On linux-2.6.21-rc2 or later, IPv6 link-local address is not assigned to
> > > some kind of interfaces during system start-up. (I found this issue
> > > occures with e100, e1000 and tg3.)
> > 
> > Here is an alternative fix.
> > 
> > [IPV6]: Do not set IF_READY if device is down
> > 
> > Now that we add the IPv6 device at registration time we don't need
> > to set IF_READY in ipv6_add_dev anymore because we will always get
> > a NETDEV_UP event later on should the device ever become ready.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Indeed, this looks like it will do the right thing.
> 
> And if you look into the history of the code in this area
> I think you'll find that this snippet being removed existed
> exactly because inet6_dev creation happened long after the
> device was registered.

I understand. Thanks.
And I thank Herbert to provide suitable fix.

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>

