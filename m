From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: do schedule napi after testing for it
Date: Wed, 14 Jan 2009 21:49:48 -0800 (PST)
Message-ID: <20090114.214948.75946431.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955478-11495-1-git-send-email-n0-1@freewrt.org>
	<200901141859.05053.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47695
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754520AbZAOFtr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:49:47 -0500
In-Reply-To: <200901141859.05053.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 18:59:04 +0100

> Le Wednesday 14 January 2009 18:51:18 Phil Sutter, vous avez =E9crit=A0=
:
> > The called netif_rx_schedule() does all the work for us:
> > - it checks the return value of netif_rx_schedule_prep() and
> > - if everything is ok calls __netif_rx_schedule().
> > Before this change, the driver received absolutely nothing.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
