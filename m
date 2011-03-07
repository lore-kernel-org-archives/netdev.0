From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 13/17] mlx4: Add blue flame support for kernel consumers
Date: Mon, 07 Mar 2011 13:27:21 -0800 (PST)
Message-ID: <20110307.132721.246531926.davem@davemloft.net>
References: <4D74B0D2.1000907@mellanox.co.il>
	<AANLkTi=uRL2GAb7CBqJiVUuXTgpX_w7=3PZ3JdmL_+jj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org, eli@mellanox.co.il
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59582
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756353Ab1CGV0q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 16:26:46 -0500
In-Reply-To: <AANLkTi=uRL2GAb7CBqJiVUuXTgpX_w7=3PZ3JdmL_+jj@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Roland Dreier <roland@purestorage.com>
Date: Mon, 7 Mar 2011 13:07:48 -0800

> On Mon, Mar 7, 2011 at 2:17 AM, Yevgeny Petrilin
> <yevgenyp@mellanox.co.il> wrote:
>> + =A0 =A0 =A0 if (map_bf_area(dev))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mlx4_dbg(dev, "Kernel support for blue=
 flame is not available for kernels < 2.6.28\n");
>=20
> This seems like a really bad error message.  Can map_bf_area() actual=
ly fail?

Indeed, referencing specific old kernel versions in the upstream
driver makes no sense at all.
