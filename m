From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 15:22:49 -0700 (PDT)
Message-ID: <20070718.152249.43010301.davem@davemloft.net>
References: <469E16C5.4000102@trash.net>
	<200707181544.11890.florian.fainelli@telecomint.eu>
	<469E1BB0.2040104@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian.fainelli@telecomint.eu, netdev@vger.kernel.org,
	rpurdie@rpsys.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52845
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752317AbXGRWWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 18:22:50 -0400
In-Reply-To: <469E1BB0.2040104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 18 Jul 2007 15:54:56 +0200

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

Yes please, calling this millions of times per second on a high end
router is just not smart.
