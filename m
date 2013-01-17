From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and <linux/in6.h>
Date: Thu, 17 Jan 2013 12:10:24 +0900
Message-ID: <50F76BA0.90502@linux-ipv6.org>
References: <50F6B761.8070106@linux-ipv6.org> <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com> <201301161205.04502.vapier@gentoo.org> <20130116.135744.697469565804508454.davem@davemloft.net> <50F75EA7.4060309@systemhalted.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vapier@gentoo.org,
	libc-alpha@sourceware.org, bhutchings@solarflare.com,
	amwang@redhat.com, tmb@mageia.org, eblake@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Carlos O'Donell <carlos@systemhalted.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50F75EA7.4060309@systemhalted.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Carlos O'Donell wrote:
> diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
> index f79c372..a2b16a5 100644
> --- a/include/uapi/linux/in6.h
> +++ b/include/uapi/linux/in6.h
:
>  #define IPV6_PRIORITY_14		0x0e00
>  #define IPV6_PRIORITY_15		0x0f00
>  
> +
> +#ifndef _NETINET_IN_H
> +#if defined (__GLIBC__)
> +/* Include all of the other IPPROTO_* defines for userspace. */
> +#include <linux/ipproto.h>
> +#endif
>  /*
>   *	IPV6 extension headers

Overall, it looks good, but why including linux/ipproto.h?

--yoshfuji
