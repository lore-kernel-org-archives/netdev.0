From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next v3 1/2] inetpeer: add namespace support for inetpeer
Date: Fri, 08 Jun 2012 21:26:42 +0800
Message-ID: <4FD1FD92.1050301@cn.fujitsu.com>
References: <1339154441-4513-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:18960 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab2FHN0R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 09:26:17 -0400
In-Reply-To: <1339154441-4513-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B406=E6=9C=8808=E6=97=A5 19:20, Gao feng =E5=86=99=
=E9=81=93:
> now inetpeer doesn't support namespace,the information will
> be leaking across namespace.
>=20
> this patch move the global vars v4_peers and v6_peers to
> netns_ipv4 and netns_ipv6 as a field peers.
>=20
> add struct pernet_operations inetpeer_ops to initial pernet
> inetpeer data.
>=20
> and change family_to_base and inet_getpeer to support namespace.
>=20
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---

It seams I send two v3 patch.
Please ignore this duplicate,There must be some wrong with my mail clie=
nt.

Thanks Eric for reminding me this.
