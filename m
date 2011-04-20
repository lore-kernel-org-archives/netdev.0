From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: tun: convert to hw_features
Date: Wed, 20 Apr 2011 12:52:24 +0930
Message-ID: <871v0xip3j.fsf@rustcorp.com.au>
References: <20110419161310.7508513909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?utf-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60408 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478Ab1DTWce convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 18:32:34 -0400
In-Reply-To: <20110419161310.7508513909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2011 18:13:10 +0200 (CEST), Micha=C5=82 Miros=C5=82aw <m=
irq-linux@rere.qmqm.pl> wrote:
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

Err, not in my git tree!  It predates git in fact.

Since tap requires privs, I wouldn't worry about invalid packets too
much.

Thanks,
Rusty.
