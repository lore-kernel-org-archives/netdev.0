From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: 2.6.12-rc4-mm[12] - ULOG problem
Date: Wed, 18 May 2005 22:27:29 -0700
Message-ID: <20050518222729.007887b8.akpm@osdl.org>
References: <20050518202458.55a63d37.akpm@osdl.org>
	<E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DYcyg-0005fP-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
>  > 
>  > This is the second report of this happening.
>  > 
>  > FATAL: Error inserting ipt_ULOG (/lib/modules/2.6.12-rc4-mm1-2/kernel/net/ipv4/netfilter/ipt_ULOG.ko): Cannot allocate memory

Ah yes, thanks.  netlink_kernel_create() has a dumbish return-value protocol.

>  This probably means that someone has stolen the NETLINK_NFLOG id.

cn_init() uses NETLINK_NFLOG.  Peculiar.
