From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] veth: remove unneeded ifname code from
 veth_newlink()
Date: Mon, 02 May 2011 15:55:11 -0700 (PDT)
Message-ID: <20110502.155511.245414556.davem@davemloft.net>
References: <20110124154546.GA2689@psychotron.brq.redhat.com>
	<BANLkTi=x8xi7-g3SZdva7Ndg0a4EY1NK8g@mail.gmail.com>
	<20110430112817.GD2658@psychotron.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, netdev@vger.kernel.org, xemul@openvz.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758984Ab1EBWzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 18:55:43 -0400
In-Reply-To: <20110430112817.GD2658@psychotron.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 30 Apr 2011 13:28:17 +0200

> Fri, Apr 22, 2011 at 11:43:10AM CEST, mirqus@gmail.com wrote:
>>2011/1/24 Jiri Pirko <jpirko@redhat.com>:
>>> The code is not needed because tb[IFLA_IFNAME] is already
>>> processed in rtnl_newlink(). Remove this redundancy.
>>>
>>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>>
>>Hi. This patch broke creation of veth devices. Reverting it fixes the=
 issue.
>=20
> Sorry for troubles.
>=20
> For net-next-2.6 this is fixed by:
> http://patchwork.ozlabs.org/patch/93498/
>=20
> For net-2.6 I suggest to revert this patch:
>=20
> Subject: [PATCH net-2.6] Revert: veth: remove unneeded ifname code fr=
om veth_newlink()
>=20
> 84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743 caused regression on veth
> creation. This patch reverts the original one.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, with "Reported-by: " added to give credit to Micha=A9=A9 Miros=
=A9=A9aw.
