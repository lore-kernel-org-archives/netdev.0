From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6]: IPv6: strcpy -> strlcpy
Date: Thu, 27 Nov 2003 17:33:20 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127.173320.19253188.yoshfuji@linux-ipv6.org>
References: <1069920883.2476.1.camel@teapot.felipe-alfaro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: felipe_alfaro@linuxmail.org
In-Reply-To: <1069920883.2476.1.camel@teapot.felipe-alfaro.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1069920883.2476.1.camel@teapot.felipe-alfaro.com> (at Thu, 27 Nov 2003 09:14:44 +0100), Felipe Alfaro Solana <felipe_alfaro@linuxmail.org> says:

> Attached is a patch against 2.6.0-test11 to convert all strcpy() calls
> to their corresponding strlcpy() for IPv6. Compiled and tested.

I don't like this coding style.

diff -uNr linux-2.6.0-test11.orig/net/ipv6/ip6_tunnel.c linux-2.6.0-test11/net/ipv6/ip6_tunnel.c
--- linux-2.6.0-test11.orig/net/ipv6/ip6_tunnel.c	2003-11-26 21:42:56.000000000 +0100
+++ linux-2.6.0-test11/net/ipv6/ip6_tunnel.c	2003-11-27 00:27:09.000000000 +0100
-	strcpy(t->parms.name, dev->name);
+	strlcpy(t->parms.name, dev->name, IFNAMSIZ);
                                          sizeof(t->parms.name)

or something like that.

--yoshfuji
