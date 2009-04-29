From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Wed, 29 Apr 2009 10:52:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904291028060.20858@tyr.diku.dk>
References: <1240911369.10689.20.camel@localhost.localdomain>
 <1240925799.3200.16.camel@achroite> <1240938258.3200.28.camel@achroite>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42393 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbZD2Iw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 04:52:57 -0400
In-Reply-To: <1240938258.3200.28.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2009, Ben Hutchings wrote:

> I wrote:
>> However, I
>> think your time might be better spent in fixing the air flow in the
>> computer before the board is permanently damaged.
>
> It may also be worth checking that the sensors are actually reading
> correctly.  You can read them using the "sensors" command from the
> lm_sensors package or by running:
>
>    grep . /sys/class/net/eth88/device/i2c-adapter:*/*-002e/temp*_input
>
> Divide the numbers by 1000 to get temperatures in degrees celsius.

/sys/class/net/eth88/device/i2c-adapter:i2c-1/1-002e/temp1_input:61000
/sys/class/net/eth88/device/i2c-adapter:i2c-1/1-002e/temp2_input:70000

Guess the temperature is fairly high... I can touch it with a finger 
without getting burned.  I also have a 10GbE Sun Neptune (niu) in the 
machine, if I touch the heatsink on that I burn my finger, so that is even 
hotter...


> The "internal" temperature sensor (temp1_input) is in the LM87, which is
> placed at the corner of the board away from the bracket and the edge
> connector.
>
> The "external" temperature sensor (temp2_input) is in the SFC4000.

I though this was read from the XFP.  I was hoping the NIC supported 
reading i2c stuff from the XFP.  Does it support that? (Robert Olsson 
wanted to play with this stuff)


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
