From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 3/4] gigaset: reduce syslog clutter
Date: Tue, 23 Feb 2010 13:53:16 +0100
Message-ID: <4B83CFBC.5030406@imap.cc>
References: <1266899531.9265.4.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:34779 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab0BWMxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 07:53:19 -0500
In-Reply-To: <1266899531.9265.4.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches schrieb:
> Perhaps it'd be useful to add a ethtool/netif_msg interface
> and classify the messages as appropriate.

Interesting idea. On first glance, however, I don't see how to map the
Gigaset driver's diverse debugging categories (like USB communication
vs. V.25ter communication vs. ISDN subsystem communication) to the
NETIF_MSG_ flags in a useful way.

What's more, ethtool only seems to allow the setting of a numerical
message "level" enabling all debug flags "below" that level. It cannot
enable, for example, NETIF_MSG_TX_ERR without NETIF_MSG_PROBE. The
Gigaset driver OTOH follows the concept of individually selectable areas
of interest. In fact, I make frequent use of that ability when I help a
user with troubleshooting. For example, a typical first setting for a
user who cannot make an ISDN connection would be the value 0x102020
mentioned in the README.

OTOH, the ability to control the "non-debug" verbosity of the Gigaset
driver (ie. the messages not controlled by the "debug" parameter) with
ethtool/netif_msg might be appreciated. Perhaps that's what you had in mind?

Thanks,
Tilman
