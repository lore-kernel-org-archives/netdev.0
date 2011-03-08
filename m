From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/17] mlx4_en: Enabling new steering
Date: Tue, 08 Mar 2011 14:26:49 -0800 (PST)
Message-ID: <20110308.142649.183050876.davem@davemloft.net>
References: <4D74B0C9.9020108@mellanox.co.il>
	<AANLkTikftARWMbmy8zHbRShBbbnQhXhiequzdR_aPBst@mail.gmail.com>
	<AANLkTim8XDT5YKJc4wroyEDJc1X+xZOFL9y_090F5eLr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: or.gerlitz@gmail.com, yevgenyp@mellanox.co.il,
	netdev@vger.kernel.org, vlad@mellanox.co.il, nirmu@mellanox.com,
	alekseys@mellanox.com
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754819Ab1CHW0M convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 17:26:12 -0500
In-Reply-To: <AANLkTim8XDT5YKJc4wroyEDJc1X+xZOFL9y_090F5eLr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roland Dreier <roland@kernel.org>
Date: Tue, 8 Mar 2011 13:30:25 -0800

> On Tue, Mar 8, 2011 at 1:10 PM, Or Gerlitz <or.gerlitz@gmail.com> wro=
te:
>>> + =A0 =A0 =A0 if (mdev->dev->caps.vep_mc_steering && ibqp->qp_type =
=3D=3D IB_QPT_RAW_ETHERTYPE) {
>>
>> Guys,
>>
>> Didn't you want to refer here to the "raw ethernet QP" which is type=
d
>> to IB_QPT_RAW_PACKET by the series posted on December last year, see
>> http://marc.info/?l=3Dlinux-rdma&m=3D129162076818154 =A0--
>> IB_QPT_RAW_ETHERTYPE =A0is a rename of IB's IB_QPT_RAW_ETY done by
>> commit a2ebf07ae53e65bd073f96877e4818f2e89271ae
>=20
> Good catch.  I think the drivers/infiniband part of this patch should
> just be dropped -- we don't have any raw QP support of any kind, righ=
t?

Once this is all sorted out, please someone respin this entire patch
set.

Thanks.
