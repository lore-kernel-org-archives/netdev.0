From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 1/3] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Wed, 8 Jan 2014 06:02:25 +0100
Message-ID: <20140108050225.GO30393@order.stressinduktion.org>
References: <20140106084827.GA5766@order.stressinduktion.org> <20140107.191314.881648861654097224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johnwheffner@gmail.com, steffen.klassert@secunet.com,
	fweimer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47154 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbaAHFC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 00:02:27 -0500
Content-Disposition: inline
In-Reply-To: <20140107.191314.881648861654097224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

On Tue, Jan 07, 2014 at 07:13:14PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 6 Jan 2014 09:48:27 +0100
> 
> > +ip_forward_use_pmtu - BOOLEAN
> > +	By default we don't trust protocol path MTUs while forwarding
> > +	because they could be easily forged and can lead to unwanted
> > +	fragmentation by the router.
> > +	You only need to enable this if you have user-space software
> > +	which tries to discover path mtus by itself and depends on the
> > +	kernel honoring this information. This is normally not the
> > +	case.
> > +	Default: 0 (disabled)
> > +	Possible values:
> > +	0 - disabled
> > +	1 - enabled
> 
> You made this default to off, great, but the description text still says
> that we don't trust PMTU information by default :-)

Hm, sorry, but I don't see the contradiction.

> > +static inline unsigned int ip_dst_mtu_secure(const struct dst_entry *dst,
> 
> Please do me a favor and remove the "_secure" bit from this helper function
> name.  This function doesn't implicitly do anything "secure", rather it
> simply calculates the dst's mtu based upon various conditions.

I'll follow the IPv6 one and will switch to _forward postfix.

Thanks,

  Hannes
