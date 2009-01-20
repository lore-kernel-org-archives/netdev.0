From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: adjust headroom for new skb's also
Date: Mon, 19 Jan 2009 16:23:44 -0800 (PST)
Message-ID: <20090119.162344.127068009.davem@davemloft.net>
References: <1232058598-15811-1-git-send-email-n0-1@freewrt.org>
	<20090115223020.A7EED4043838@mail.nwl.cc>
	<200901192207.46383.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764716AbZATAXm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 19:23:42 -0500
In-Reply-To: <200901192207.46383.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Mon, 19 Jan 2009 22:07:45 +0100

> Le Thursday 15 January 2009 23:29:56 Phil Sutter, vous avez =E9crit=A0=
:
> > This is copy and paste from the original driver. As skb_reserve() i=
s
> > also called within korina_alloc_ring() when initially allocating th=
e
> > receive descriptors, the same should be done when allocating new sp=
ace
> > after passing an skb to upper layers.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
