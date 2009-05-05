From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: 6rd iproute2 support
Date: Tue, 05 May 2009 22:16:10 +0900 (JST)
Message-ID: <20090505.221610.64122023.yoshfuji@linux-ipv6.org>
References: <20090505105050.GA2598@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: acassen@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:1540 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbZEENQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 09:16:29 -0400
In-Reply-To: <20090505105050.GA2598@lnxos.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <20090505105050.GA2598@lnxos.staff.proxad.net> (at Tue, 5 May 2009 12:50:50 +0200), Alexandre Cassen <acassen@freebox.fr> says:

> IPv6 rapid deployment (6rd) builds upon mechanisms of 6to4 (RFC3056)
> to enable a service provider to rapidly deploy IPv6 unicast service
> to IPv4 sites to which it provides customer premise equipment.  Like
> 6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
> transit IPv4-only network infrastructure.  Unlike 6to4, a 6rd service
> provider uses an IPv6 prefix of its own in place of the fixed 6to4
> prefix. more info at http://tools.ietf.org/html/draft-despres-6rd-03.
> 
> Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
> ---
>  include/linux/if_tunnel.h |    5 +++++
>  ip/iptunnel.c             |   16 +++++++++++++++-
>  2 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
> index 2918c6f..00092e0 100644
> --- a/include/linux/if_tunnel.h
> +++ b/include/linux/if_tunnel.h
> @@ -30,6 +30,11 @@ struct ip_tunnel_parm
>  	__be16			o_flags;
>  	__be32			i_key;
>  	__be32			o_key;
> +
> +	/* 6rd matching params */
> +	struct in6_addr		ip6rd_zone;
> +	__u8			ip6rd_prefix;
> +
>  	struct iphdr		iph;
>  };
>  

Sorry, you cannot change this struct this way because you break
existing applications.

--yoshfuji
