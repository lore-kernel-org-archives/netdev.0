From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tun: convert to hw_features
Date: Wed, 20 Apr 2011 01:32:16 -0700 (PDT)
Message-ID: <20110420.013216.28818575.davem@davemloft.net>
References: <20110419161310.7508513909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55433
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752493Ab1DTIcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:32:51 -0400
In-Reply-To: <20110419161310.7508513909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Tue, 19 Apr 2011 18:13:10 +0200 (CEST)

> This changes offload setting behaviour to what I think is correct:
>  - offloads set via ethtool mean what admin wants to use (by default
>    he wants 'em all)
>  - offloads set via ioctl() mean what userspace is expecting to get
>    (this limits which admin wishes are granted)
>  - TUN_NOCHECKSUM is ignored, as it might cause broken packets when
>    forwarded (ip_summed =3D=3D CHECKSUM_UNNECESSARY means that checks=
um
>    was verified, not that it can be ignored)
>=20
> If TUN_NOCHECKSUM is implemented, it should set skb->csum_* and
> skb->ip_summed (=3D CHECKSUM_PARTIAL) for known protocols and let oth=
ers
> be verified by kernel when necessary.
>=20
> TUN_NOCHECKSUM handling was introduced by commit
> f43798c27684ab925adde7d8acc34c78c6e50df8:
>=20
>     tun: Allow GSO using virtio_net_hdr
>    =20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Applied.
