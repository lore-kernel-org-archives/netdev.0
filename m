From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Tue, 28 Apr 2009 18:04:18 +0100
Message-ID: <1240938258.3200.28.camel@achroite>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:46579 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932971AbZD1REW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 13:04:22 -0400
In-Reply-To: <1240925799.3200.16.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wrote:
> However, I
> think your time might be better spent in fixing the air flow in the
> computer before the board is permanently damaged.

It may also be worth checking that the sensors are actually reading
correctly.  You can read them using the "sensors" command from the
lm_sensors package or by running:

    grep . /sys/class/net/eth88/device/i2c-adapter:*/*-002e/temp*_input

Divide the numbers by 1000 to get temperatures in degrees celsius.

The "internal" temperature sensor (temp1_input) is in the LM87, which is
placed at the corner of the board away from the bracket and the edge
connector.

The "external" temperature sensor (temp2_input) is in the SFC4000.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

