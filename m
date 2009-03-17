From: "Tomi Orava" <tomimo@ncircle.nullnet.fi>
Subject: Re: [Bugme-new] [Bug 12886] New: skge wake on lan
Date: Tue, 17 Mar 2009 12:15:20 +0200 (EET)
Message-ID: <9e1133f653c918ec3c19c8fe28452a9f.squirrel@ncircle.nullnet.fi>
References: <bug-12886-10286@http.bugzilla.kernel.org/>
    <20090316200428.908245dc.akpm@linux-foundation.org>
    <200903171101.32812.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:55577 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756972AbZCQKXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:23:44 -0400
In-Reply-To: <200903171101.32812.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

> Please tell me what exactly you do to set up WoL.

The only thing I do is I configure the WOL bios option
to on ie. no OS based configuration settings are touched.

The previously mentioned patch reverted the ethtool output is
(ie. this is a working 2.6.28.7 system atm):

Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pg
        Wake-on: g
        Current message level: 0x00000037 (55)
        Link detected: yes

Regards,
Tomi O.

-- 


