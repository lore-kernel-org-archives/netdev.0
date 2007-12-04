From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: e1000 driver problems
Date: Tue, 4 Dec 2007 18:08:27 +0100
Message-ID: <20071204170827.GH8704@ics.muni.cz>
References: <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com> <20071204153405.GG8704@ics.muni.cz> <Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Matt Mathis <mathis@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:45010 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbXLDRIl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 12:08:41 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 11:02:23AM -0500, Matt Mathis wrote:
> This is probably not an e1000 problem, but a general Ethernet "featur=
e". =20
> If you defeat auto-negotiation to force the data rate, you implicitly=
=20
> defeat duplex negotiation as well.  You need to explicitly set the du=
plex=20
> mode.

ethtool reports, that I have full duplex line:
ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supports auto-negotiation: Yes
        Advertised link modes:  Not reported
        Advertised auto-negotiation: No
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: off
        Supports Wake-on: umbg
        Wake-on: d
        Current message level: 0x00000007 (7)
        Link detected: yes


--=20
Luk=E1=B9 Hejtm=E1nek
