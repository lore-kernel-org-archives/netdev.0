From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Autoconfig link-local address on ip6-ip6 tunnel
 device
Date: Tue, 25 Nov 2003 03:55:31 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031125.035531.94714784.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.58.0311051412180.28216@rhea.tcs.hut.fi> (at Wed, 5 Nov 2003 15:07:32 +0200 (EET)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> this (rewritten) patch configures link-local addresses to the ip6-ip6
> tunnel devices so you can run link-local protocols over them. If you are
> ok with the patch, perhaps we could push it forward to Dave.

Sorry for long silence.

> +static inline int
> +ip6_tnl_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
> +{
> +	struct in6_addr lladdr;
> +
> +	if (!ipv6_get_lladdr(link_dev, &lladdr)) {
> +		addrconf_add_linklocal(idev, &lladdr);
> +		return 0;
> +	}
> +	return -1;
> +}
> +

I prefer ipv6_inherit_linklocal() or something like that
because this does not seem ip6_tun specific.

I'm ok with other portion.

Thanks.

--yoshfuji
