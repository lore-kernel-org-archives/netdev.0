From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [NET] net: reorder struct net_device_ops
Date: Fri, 20 Mar 2009 13:53:45 +0100
Message-ID: <49C391D9.20308@cosmosbay.com>
References: <49C354B5.3060404@cosmosbay.com>	<20090320.013611.67498837.davem@davemloft.net>	<49C36570.4010903@cosmosbay.com> <87iqm4jr8z.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56744 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbZCTMyA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 08:54:00 -0400
In-Reply-To: <87iqm4jr8z.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork a =C3=A9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>> [NET] net: reorder struct net_device_ops
>>
>> Moving ndo_start_xmit() field at first position in
>> struct net_device_ops reduce the assembly needed to compute
>> the prefetch() address.
>=20
> You can't do this while the compatibility code is still there.
>=20
> from net/core/dev.c:register_netdevice() :
>=20
> 		/* This works only because net_device_ops and the
> 		   compatiablity structure are the same. */
> 		dev->netdev_ops =3D (void *) &(dev->init);
>=20
>=20
> Bj=C3=B8rn

Nice catch !

Yes, very true, but I discarded this patch anyway, I wont correct this.

Thank you


