From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: e1000 driver problems
Date: Tue, 4 Dec 2007 16:34:05 +0100
Message-ID: <20071204153405.GG8704@ics.muni.cz>
References: <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com> <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:45950 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753206AbXLDPeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 10:34:14 -0500
Content-Disposition: inline
In-Reply-To: <47541ED0.9090808@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another problem at my own machine. If I force speed to 100Mb on 1GE net=
work,
I can reach 95Mbps bidirectional using UDP (0.34% loses) but only 1.2Mb=
ps
using TCP. A bug? If I enable autonegotiation and run at 1GE, I can got=
 95Mb
on TCP to the target machine (the target machine has only 100Mb connect=
ion).

--=20
Luk=E1=B9 Hejtm=E1nek
