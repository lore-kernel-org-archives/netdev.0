From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: do not use IRQF_SHARED with IRQF_DISABLED
Date: Wed, 14 Jan 2009 21:51:57 -0800 (PST)
Message-ID: <20090114.215157.72519595.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955540-12886-1-git-send-email-n0-1@freewrt.org>
	<200901141900.51134.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbZAOFv4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:51:56 -0500
In-Reply-To: <200901141900.51134.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 19:00:50 +0100

> Le Wednesday 14 January 2009 18:52:20 Phil Sutter, vous avez =E9crit=A0=
:
> > As the kernel warning states: "IRQF_DISABLED is not guaranteed on s=
hared
> > IRQs". Since these IRQs' values are hardcoded and my test system do=
esn't
> > show any shared use of IRQs at all, rather make them non-shared tha=
n
> > non-disabled.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Also applied, thanks everyone.
