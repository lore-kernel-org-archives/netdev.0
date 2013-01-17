From: David Miller <davem@davemloft.net>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 22:15:38 -0500 (EST)
Message-ID: <20130116.221538.1756411165313441486.davem@davemloft.net>
References: <201301161205.04502.vapier@gentoo.org>
	<20130116.135744.697469565804508454.davem@davemloft.net>
	<50F75EA7.4060309@systemhalted.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, libc-alpha@sourceware.org,
 bhutchings@solarflare.com, yoshfuji@linux-ipv6.org, amwang@redhat.com,
 tmb@mageia.org, eblake@redhat.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, libvirt-list@redhat.com, tgraf@suug.ch,
 schwab@suse.de
To: carlos@systemhalted.org
Return-path: <libc-alpha-return-36351-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <50F75EA7.4060309@systemhalted.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

From: Carlos O'Donell <carlos@systemhalted.org>
Date: Wed, 16 Jan 2013 21:15:03 -0500

> +/* If a glibc-based userspace has already included in.h, then we will not 
> + * define in6_addr (nor the defines), sockaddr_in6, or ipv6_mreq. The
> + * ABI used by the kernel and by glibc match exactly. Neither the kernel
> + * nor glibc should break this ABI without coordination.
> + */
> +#ifndef _NETINET_IN_H
> +

I think we should shoot for a non-glibc-centric solution.

I can't imagine that other libc's won't have the same exact problem
with their netinet/in.h conflicting with the kernel's, redefining
structures like in6_addr, that we'd want to provide a protection
scheme for here as well.

Let's pick some more generic names and themes for the CPP macros and
comments we use to protect the header file blocks and describe that
protection scheme.

Thanks.
