From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 3200] New: linux-2.6.8-rc4-mm1: IPv6-in-IPv6 undefined references
Date: Sun, 15 Aug 2004 17:41:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BwFe4-0007hy-00@gondolin.me.apana.org.au>
References: <20040814233108.51a04d33.akpm@osdl.org>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20040814233108.51a04d33.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> As module:
> 
> **********
> make[1]: `arch/i386/kernel/asm-offsets.s' is up to date.
>  CHK     include/linux/compile.h
> Kernel: arch/i386/boot/bzImage is ready
>  Building modules, stage 2.
>  MODPOST
> *** Warning: "xfrm6_tunnel_deregister" [net/ipv6/ip6_tunnel.ko] undefined!
> *** Warning: "xfrm6_tunnel_register" [net/ipv6/ip6_tunnel.ko] undefined!

This patch should fix it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/ipv6/Kconfig 1.9 vs edited =====
--- 1.9/net/ipv6/Kconfig	2004-07-30 08:48:33 +10:00
+++ edited/net/ipv6/Kconfig	2004-08-15 17:39:29 +10:00
@@ -59,6 +59,7 @@
 config IPV6_TUNNEL
 	tristate "IPv6: IPv6-in-IPv6 tunnel"
 	depends on IPV6
+	select XFRM
 	---help---
 	  Support for IPv6-in-IPv6 tunnels described in RFC 2473.
 
