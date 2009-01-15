From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: do tx at the right position
Date: Wed, 14 Jan 2009 21:50:19 -0800 (PST)
Message-ID: <20090114.215019.258308916.davem@davemloft.net>
References: <1231955400-9745-1-git-send-email-n0-1@freewrt.org>
	<1231955495-11911-1-git-send-email-n0-1@freewrt.org>
	<200901141859.19609.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754537AbZAOFuS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:50:18 -0500
In-Reply-To: <200901141859.19609.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Wed, 14 Jan 2009 18:59:19 +0100

> Le Wednesday 14 January 2009 18:51:35 Phil Sutter, vous avez =E9crit=A0=
:
> > Triggering TX before the write to the DMA status mask register lead=
s to
> > transferring packets with maximum payload no matter what the actual
> > packet size is.
> > While here, also trigger RX scheduling after writing the DMA status=
 mask
> > register, like it was in the original driver before it was sent
> > upstream.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

Applied.
