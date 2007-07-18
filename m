From: Richard Purdie <rpurdie@rpsys.net>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 15:10:44 +0100
Message-ID: <1184767844.21219.3.camel@localhost.localdomain>
References: <200707181527.38895.florian.fainelli@telecomint.eu>
	 <469E16C5.4000102@trash.net>
	 <200707181544.11890.florian.fainelli@telecomint.eu>
	 <469E1BB0.2040104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian.fainelli@telecomint.eu>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tim.rpsys.net ([194.106.48.114]:41520 "EHLO tim.rpsys.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754289AbXGROKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 10:10:54 -0400
In-Reply-To: <469E1BB0.2040104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-18 at 15:54 +0200, Patrick McHardy wrote:
> Florian Fainelli wrote:
> >> Besides missing a declaration and not linking without the network
> >> LED config option, its pretty ridiculous to call this for every
> >> packet just to make a led blink.
> >>     
> >
> > Could you suggest me a better way to do so ? The code was highly inspired from 
> > what is done with the IDE trigger. The declaration is done in linux/leds.h, 
> > which is included in dev.c for that purpose.
> >   
> 
> Maybe just increment a variable and periodically check it or something
> like that.

Are there not already packet counters that the LED trigger could just
look at? If it did that at say 20Hz or 10Hz, it would probably look
quite reasonable without impacting on the system too much?

Richard

