From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH net-next] bridge: remove extern from function prototypes
Date: Thu, 26 Dec 2013 14:39:23 +0800
Message-ID: <52BBCF1B.1010901@cn.fujitsu.com>
References: <52BBCA57.9080706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:24495 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab3LZGjj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 01:39:39 -0500
In-Reply-To: <52BBCA57.9080706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm so sorry, there is something wrong with it,
please just ignore this patch!

=D3=DA 2013=C4=EA12=D4=C226=C8=D5 14:19, Duan Jiong =D0=B4=B5=C0:
>=20
> There are a mix of function prototypes with and without extern
> in the kernel sources. Standardize on not using extern for
> function prototypes.
>=20
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler. Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.
>=20
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> ---
>  net/bridge/br_private.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 2e77d92..458889e 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -762,7 +762,7 @@ unsigned long br_timer_value(const struct timer_l=
ist *timer);
> =20
>  /* br.c */
>  #if IS_ENABLED(CONFIG_ATM_LANE)
> -extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned=
 char *addr);
> +int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *=
addr);
>  #endif
> =20
>  /* br_netlink.c */
>=20
