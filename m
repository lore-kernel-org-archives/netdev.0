From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] l2tp: add support for IPv4-mapped IPv6 addresses
Date: Tue, 01 Oct 2013 12:38:02 -0400 (EDT)
Message-ID: <20131001.123802.1954246085474040631.davem@davemloft.net>
References: <524A7FB7.40304@init-sys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: f.cachereul@init-sys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3JAQiO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:38:14 -0400
In-Reply-To: <524A7FB7.40304@init-sys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fran=E7ois Cachereul <f.cachereul@init-sys.com>
Date: Tue, 01 Oct 2013 09:54:31 +0200

> @@ -1620,6 +1621,8 @@ int l2tp_tunnel_create(struct net *net, int fd,=
 int version, u32 tunnel_id, u32
>  	int err;
>  	struct socket *sock =3D NULL;
>  	struct sock *sk =3D NULL;
> +#if IS_ENABLED(CONFIG_IPV6)
> +#endif
>  	struct l2tp_net *pn;
>  	enum l2tp_encap_type encap =3D L2TP_ENCAPTYPE_UDP;
> =20

Please get rid of this.
