From: Ben Greear <greearb@candelatech.com>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Tue, 09 Dec 2003 14:38:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD64EC9.6010203@candelatech.com>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com> <20031209223214.A1855@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031209223214.A1855@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:

> What do you propose? Do we need something like
> 
> int vlan_adjust_mtu (int mtu)
> {
> #ifdef CONFIG_VLANN_8021Q
> 	return (mtu - VLAN_HLEN);
> #else
> 	return (mtu);
> #endif
> }
> 
> and
> 
> int foobar_change_mtu (struct net_device *dev, int mtu)
> {
> 	mtu = vlan_adjust_mtu (mtu);
> 	/* check hardware limits. */
> 	...
> 	dev->mtu = mtu;
> 	return (0);
> }
> 
> ? Ben, this would also keep you happy, right?

I was thinking the check could be made run-time, but in reality, this is
a very minor detail.  It may be better to just hard-code it like you
had it originally.  I don't like the patch above, I'd rather see the
#ifdef when checking for the maximum hardware limit, if anywhere.

Thanks,
Ben

> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
