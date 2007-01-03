From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Wed, 03 Jan 2007 17:20:05 +1100
Message-ID: <1167805205.6165.141.camel@localhost.localdomain>
References: <1167800285.6165.105.camel@localhost.localdomain>
	 <20070102.211158.35016452.davem@davemloft.net>
	 <1167801614.6165.117.camel@localhost.localdomain>
	 <20070102.212605.15263907.davem@davemloft.net>
	 <1167802802.6165.129.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55071 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423AbXACGUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 01:20:11 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <1167802802.6165.129.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The one with only asym. support is a big Cisco Catalyst 3350 (well.. big
> but not that many ports :-)

Ok, I got in the config of the switch with somebody who knows how to
speak ciscong, and it seems that it defaults to flow control "desired"
for send and "off" for receive on all ports, which means it will indeed
only advertise support for asymetrical flow control.

We've changed the setting for the port on which my sungem g5 is
connected to "desired" on both send and receive, and it now advertises
flow control on both, and sungem does pick it up properly.

So it's indeed the default setting of those cisco switches that seem to
not quite match what drivers like sungem or tg3 like.

Ben.


