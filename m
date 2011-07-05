From: Michael Guntsche <mike@it-loops.com>
Subject: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks DHCP setup
Date: Tue, 5 Jul 2011 20:43:40 +0200
Message-ID: <20110705204200@it-loops.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: xu@gibson.comsick.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:51684
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750823Ab1GESuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:50:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After updating from 3.0.0-rc5 to rc6 I noticed that my cellphone was no
longer able to get an address assigned from my DHCP server. While trying
to figure out the problem I noticed that tracing with tcpdump made it
work again.

The setup I have here is the following:
PPC embedded board where the wired NIC and the wlan NIC are in a bridge.
Dnsmasq is listening on the Bridge device itself.

Looking at the changes between rc5 and rc6 I noticed commit

 bd4265fe365c0f3945d: bridge: Only flood unregistered groups to routers

For testing purposes I reverted it and the cellphone immediately got an
address even without running tcpdump. Now apparently the commit states
that the user can always force flooding behaviour to any given port by
marking it as a router but I did not find any documentation how to do
that.

Now my question? Is it "normal" that this change breaks my setup here
and if it is expected how can I force my ports to the old behaviour
without reverting the commit.

Thank you very much in advance,
Michael 
