From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: e1000 driver problems
Date: Tue, 4 Dec 2007 16:03:12 +0100
Message-ID: <20071204150312.GE8704@ics.muni.cz>
References: <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com> <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:35258 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199AbXLDPDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 10:03:19 -0500
Content-Disposition: inline
In-Reply-To: <47541ED0.9090808@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 07:20:48AM -0800, Kok, Auke wrote:
> can you open up a ticket on e1000.sf.net and fill in a full bugreport
> including
> output of all of these? :
>=20
> - ethttool -i eth0
> - ethtool -e eth0
> - lspci -vv
> - full dmesg (not just the driver parts)
> - dmidecode
> - cat /proc/interrupts
>=20
> I'd like to see if maybe we can reproduce this in our lab.

I'll try but it may take some time. Meanwhile, I found that "hung" card
transmits but does not receive anything including ARP.

--=20
Luk=E1=B9 Hejtm=E1nek
