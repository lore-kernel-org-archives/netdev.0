From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: Driver SFC: Possible bug in LM87 temperature XFP detection code
Date: Wed, 29 Apr 2009 14:11:52 +0200
Message-ID: <1241007112.8115.9.camel@localhost.localdomain>
References: <1240911369.10689.20.camel@localhost.localdomain>
	 <1240925799.3200.16.camel@achroite> <1240938258.3200.28.camel@achroite>
	 <Pine.LNX.4.64.0904291028060.20858@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49675 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758559AbZD2MLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 08:11:54 -0400
In-Reply-To: <Pine.LNX.4.64.0904291028060.20858@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-04-29 at 10:52 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 28 Apr 2009, Ben Hutchings wrote:

> > It may also be worth checking that the sensors are actually reading
> > correctly.  You can read them using the "sensors" command from the
> > lm_sensors package or by running:
> >
> >    grep . /sys/class/net/eth88/device/i2c-adapter:*/*-002e/temp*_input
> >
> > Divide the numbers by 1000 to get temperatures in degrees celsius.
> 
> /sys/class/net/eth88/device/i2c-adapter:i2c-1/1-002e/temp1_input:61000
> /sys/class/net/eth88/device/i2c-adapter:i2c-1/1-002e/temp2_input:70000
> 
> Guess the temperature is fairly high... I can touch it with a finger 
> without getting burned.  

> I also have a 10GbE Sun Neptune (niu) in the 
> machine, if I touch the heatsink on that I burn my finger, so that is even 
> hotter...

I got my hands on a InfraRed Thermometer.
The Sun NIC was 98 degrees celsius!!!


> > The "internal" temperature sensor (temp1_input) is in the LM87, which is
> > placed at the corner of the board away from the bracket and the edge
> > connector.

Measuring that point gives the correct measurement using the external
infrared thermometer.

> > The "external" temperature sensor (temp2_input) is in the SFC4000.

It was harder to measure the temperature on the NIC CPU because of its
blank surface.  I can get a reading of 66 Celcius where the sensor says
68-69 Celcius.

The XFP it self of "only" 55 Celcius.  Measured by quickly pulling it
out and measuring (and taking care of measuring on a non blank surface
point).

> I though this was read from the XFP.  I was hoping the NIC supported 
> reading i2c stuff from the XFP.  Does it support that? (Robert Olsson 
> wanted to play with this stuff)

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

