From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] div64_64 support II
Date: Tue, 06 Mar 2007 10:25:51 -0800 (PST)
Message-ID: <20070306.102551.34761735.davem@davemloft.net>
References: <20070305.162551.41660347.davem@davemloft.net>
	<20070306140412.GA1470@one.firstfloor.org>
	<d8jlkiagte5.fsf@nygaard.ping.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andi@firstfloor.org, shemminger@linux-foundation.org,
	jengelh@linux01.gwdg.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ilmari@ilmari.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59543
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965971AbXCFSZx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:25:53 -0500
In-Reply-To: <d8jlkiagte5.fsf@nygaard.ping.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: ilmari@ilmari.org (Dagfinn Ilmari Manns=E5ker)
Date: Tue, 06 Mar 2007 18:43:14 +0100

> Andi Kleen <andi@firstfloor.org> writes:
>=20
> > Actually on rereading this: is there really any Linux port
> > that emulates multiplies in software? I thought that was only
> > done on really small microcontrollers or smart cards; but anything
> > 32bit+ that runs Linux should have hardware multiply, shouldn't it?
>=20
> SPARCv7 (sun4/sun4c) doesn't have hardware mul/div. This includes
> SparcStation 1, 1+, 2, SLC, ELC, IPC and IPX.

Right and the cypress sun4m parts don't do multiply/divide in
hardware either.

I believe the Alpha does divide in software too, see
arch/alpha/lib/divide.S
