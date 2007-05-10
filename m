From: jamal <hadi@cyberus.ca>
Subject: Re: Network activity LED trigger
Date: Thu, 10 May 2007 16:27:28 -0400
Message-ID: <1178828848.4062.104.camel@localhost>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
	 <1172844668.4864.46.camel@localhost>
	 <200703021516.06638.florian.fainelli@int-evry.fr>
	 <200705102121.07962.florian.fainelli@telecomint.eu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@sirena.org.uk>, netdev@vger.kernel.org,
	Richard Purdie <rpurdie@rpsys.net>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:29606 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbXEJU1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 16:27:31 -0400
Received: by wx-out-0506.google.com with SMTP id h31so665238wxd
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:27:30 -0700 (PDT)
In-Reply-To: <200705102121.07962.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2007-10-05 at 21:21 +0200, Florian Fainelli wrote:

> Netdev people can probably comment on the place of ledtrig_network_activity(), 
> which is probably not adequate. Also the ledtrig_network_activity can be 
> network device specific for instance.

Thanks for CCing me Florian.
Yes, ledtrig_network_activity() should be device specific - given the
spot you have it at. Just pass dev->name for example and filter on
whether the user wanted that specific device.

Additionaly is there a way to sort of light different colors depending
whether it is an incoming packet or outgoing?
Then you can pass a hook number OUT in the case where you have
ledtrig_network_activity() at the moment. This way we can add
multiple hooks within the network stack.
I dont remember the original patches you posted, but could you have 
multiple LEDs as well?

cheers,
jamal



