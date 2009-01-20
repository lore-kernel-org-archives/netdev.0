From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: fix loop back of receive descriptors
Date: Mon, 19 Jan 2009 16:23:40 -0800 (PST)
Message-ID: <20090119.162340.81953132.davem@davemloft.net>
References: <20090115223005.D6F694043831@mail.nwl.cc>
	<200901192207.32649.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759879AbZATAXi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 19:23:38 -0500
In-Reply-To: <200901192207.32649.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Mon, 19 Jan 2009 22:07:30 +0100

> Le Thursday 15 January 2009 23:29:55 Phil Sutter, vous avez =E9crit=A0=
:
> > After the last loop iteration, i has the value RC32434_NUM_RDS and
> > therefore leads to an index overflow when used afterwards to addres=
s the
> > last element. This is yet another another bug introduced when rewri=
ting
> > parts of the driver for upstream preparation, as the original drive=
r
> > used 'RC32434_NUM_RDS - 1' instead.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
