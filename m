From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: fix handling tx_chain_tail
Date: Wed, 14 Jan 2009 21:50:48 -0800 (PST)
Message-ID: <20090114.215048.162780505.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955510-12240-1-git-send-email-n0-1@freewrt.org>
	<200901141900.14616.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752563AbZAOFur convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:50:47 -0500
In-Reply-To: <200901141900.14616.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 19:00:14 +0100

> Le Wednesday 14 January 2009 18:51:50 Phil Sutter, vous avez =E9crit=A0=
:
> > Originally this must have been a rewrite error when introducing
> > 'chain_index'. But the original driver did not use the previous cha=
in
> > item everywhere: when altering the address tx_chain_tail points to,=
 it
> > should move forward, not backwards.
>=20
> I think this was in the original driver as well.
>=20
> > Also this is not an "index" but rather the penultimate element in t=
he
> > chain, so rename it accordingly.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
