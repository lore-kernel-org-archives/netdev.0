From: Peter =?utf-8?q?H=C3=BCwe?= <PeterHuewe@gmx.de>
Subject: Re: Sparse Warnings: net/ipv6/route.c:521:17: sparse: context imbalance in 'rt6_probe' - different lock contexts for basic block
Date: Mon, 21 Jan 2013 21:56:57 +0100
Message-ID: <201301212156.57931.PeterHuewe@gmx.de>
References: <201301212103.18066.PeterHuewe@gmx.de> <20130121.154803.1415897555788515730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:64586 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965Ab3AUUxz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:53:55 -0500
Received: from mailout-de.gmx.net ([10.1.76.19]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0M38or-1T5hjC1prj-00svl5 for
 <netdev@vger.kernel.org>; Mon, 21 Jan 2013 21:53:53 +0100
In-Reply-To: <20130121.154803.1415897555788515730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
Am Montag, 21. Januar 2013, 21:48:03 schrieb David Miller:
> From: Peter H=C3=BCwe <PeterHuewe@gmx.de>
> Date: Mon, 21 Jan 2013 21:03:17 +0100
>=20
> > Hi YOSHIFUJI,
> >=20
> > FYI, there are new sparse warnings show up in
> >=20
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-nex=
t.git
> > branch: master
> > head:   887c95cc1da53f66a5890fdeab13414613010097
> > commit: 2152caea719657579daa3a1a57a5425a3db6d612 [185/189] ipv6: Do=
 not
> > depend on rt->n in rt6_probe().
> >=20
> >>> net/ipv6/route.c:521:17: sparse: context imbalance in 'rt6_probe'=
 -
> >=20
> > different lock contexts for basic block
> >=20
> > On latest net-next/master it's
> > net/ipv6/route.c:500:17: warning: context imbalance in 'rt6_probe' =
-
> > different lock contexts for basic block
> >=20
> >=20
> > Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> > Reported-by: Peter Huewe <peterhuewe@gmx.de>
>=20
> This is fixed by:
>=20
> commit b820bb6b996966d93a5442b5fbf803ea58e7f487
> Author: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yos=
hfuji@linux-ipv6.org>
> Date:   Mon Jan 21 09:58:50 2013 +0000

Great! Thanks.
Wasn't online a few minutes ago when I checked, so sorry for the noise.
Sparse warning is gone.

Thanks
PeterH
