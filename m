From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC] netfilter: WIP: Xtables idletimer target implementation
Date: Mon, 31 May 2010 23:31:17 +0300
Message-ID: <1275337877.11744.40.camel@powerslave>
References: <1274993689-23928-1-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1005280057190.14077@obet.zrqbmnf.qr>
	 <1275024304.3754.45.camel@powerslave>
	 <alpine.LSU.2.01.1005281001550.11570@obet.zrqbmnf.qr>
	 <1275040724.24490.121.camel@chilepepper>  <4C03DCF3.1080001@trash.net>
	 <1275333179.11744.23.camel@powerslave>
	 <alpine.LSU.2.01.1005312143470.23758@obet.zrqbmnf.qr>
	 <1275336698.11744.37.camel@powerslave>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Patrick McHardy <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Timo Teras <timo.teras@iki.fi>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:56916 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab0EaUh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 16:37:56 -0400
In-Reply-To: <1275336698.11744.37.camel@powerslave>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-31 at 22:11 +0200, Luciano Coelho wrote:
> What about my other proposal of creating generic timers and associating
> them with certain interfaces whenever we get a hit? I mean, to add the
> idletimer attribute to eg. /sys/class/net/wlan0/idletimer when a packet
> reaches the target from wlan0?

Let's forget about this other proposal.  It's not going to be efficient
at all.  It's worse than I thought at first, because we need search all
the associated_ifs in all timers whenever a packet is received.

I'll go for the other solution, which will make things much simpler and
I'll be able to remove the dependency on netdevice_notifiers
completely. :D

-- 
Cheers,
Luca.

