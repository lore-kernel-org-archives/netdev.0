From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: fix ip_tos2prio
Date: Tue, 15 Mar 2011 18:54:24 -0700 (PDT)
Message-ID: <20110315.185424.193707215.davem@davemloft.net>
References: <1300164166.2649.70.camel@edumazet-laptop>
	<20110315.155305.71104836.davem@davemloft.net>
	<1300233367.2565.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chromatix99@gmail.com, d@taht.net, netdev@vger.kernel.org,
	dan@coverfire.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48697
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894Ab1CPBxq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 21:53:46 -0400
In-Reply-To: <1300233367.2565.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Mar 2011 00:56:07 +0100

> From: Dan Siemon <dan@coverfire.com>
>=20
> ECN support incorrectly maps ECN BESTEFFORT packets to TC_PRIO_FILLER
> (1) instead of TC_PRIO_BESTEFFORT (0)
>=20
> This means ECN enabled flows are placed in pfifo_fast/prio low priori=
ty
> band, giving ECN enabled flows [ECT(0) and CE codepoints] higher drop
> probabilities.
>=20
> This is rather unfortunate, given we would like ECN being more widely
> used.
>=20
> Ref : http://www.coverfire.com/archives/2011/03/13/pfifo_fast-and-ecn=
/
>=20
> Signed-off-by: Dan Siemon <dan@coverfire.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Dave T=E4ht <d@taht.net>
> Cc: Jonathan Morton <chromatix99@gmail.com>

Applied and queued up for -stable, thanks.
