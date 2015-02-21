From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] dsa: bonding: implement HW bonding
Date: Sat, 21 Feb 2015 21:43:17 +0100
Message-ID: <20150221204317.GA29884@lunn.ch>
References: <1424429473-4601-1-git-send-email-jonasj76@gmail.com>
 <1424429473-4601-2-git-send-email-jonasj76@gmail.com>
 <54E763A6.4020505@gmail.com>
 <alpine.LNX.2.03.1502201952190.11645@hellgate.skynet>
 <20150221165715.GE2092@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Johansson <jonasj76@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org,
	Jonas Johansson <jonas.johansson@westermo.se>,
	Scott Feldman <sfeldma@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47202 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbbBUUqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2015 15:46:13 -0500
Content-Disposition: inline
In-Reply-To: <20150221165715.GE2092@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm, I'm not sure I understand correctly what the marvel hw is capable of.
> Would you care to explain it a bit ? (or maybe I should read the
> datasheet)

The mv88e6060 data sheet is publicly available. It is a rather old
chip, but i guess trunking has not changed too much since then. All
the newer chips require an NDA to get the datahseet.

What i've done before is get the switch to combine two ports into a
trunk. It will then load balance packets over the two ports. If one of
the ports fails, i.e. link down, it will then concentrate all the
traffic over the one remaining port. i.e some basic form of
redundancy/failover.

Not covered by this patchset, but what would be interesting, is
getting trunking working towards the host. Many of the recent wireless
APs have two ethernet interfaces connected to the switch. The current
DSA architecture only allows one of them to be used for traffic
to/from the host from/to the switch.

	Andrew
