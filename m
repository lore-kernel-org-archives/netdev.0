From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Thu, 30 Jun 2011 10:36:14 -0400
Message-ID: <20110630143614.GA4392@shamino.rdu.redhat.com>
References: <4DE44218.4070306@krellan.com>
 <BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
 <4DE5F3E3.2080609@krellan.com>
 <1306949723.8149.2202.camel@tardy>
 <4E04A609.7010206@fandm.edu>
 <4E0C35F4.6050901@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: janardhan.iyengar@fandm.edu,
	Janardhan Iyengar <jana.iyengar@gmail.com>, rick.jones2@hp.com,
	Yuchung Cheng <ycheng@google.com>,
	netdev <netdev@vger.kernel.org>, Bryan Ford <bryan.ford@yale.edu>
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39103 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab1F3Ogh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 10:36:37 -0400
Content-Disposition: inline
In-Reply-To: <4E0C35F4.6050901@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2011 at 01:38:12AM -0700, Josh Lehan wrote:
> On 06/24/2011 07:58 AM, Janardhan Iyengar wrote:
> > Thanks for your note.  I agree that it does seem like we're simply
> > adding to the metaphorical pile.  And my first knee-jerk response would
> > be that there's not much else one can do in the modern IPv4 Internet :-)
> 
> Thanks, I also appreciate you reviving this thread.  I was surprised at
> the hostility here, towards an idea that we both think is necessary and
> practical, given the realities of today's Internet.
> 
> TCP is at the middle of the hourglass, as you said.  Even UDP isn't
> universally allowed (it's not all that uncommon to see UDP blocked,
> except for DNS packets to whitelisted DNS servers).  At least one ISP,
> "AT&T U-Verse", no longer allows the customer their choice of Internet
> router, and the ISP's mandated router will filter all traffic in both
> directions, so if the packet isn't recognized by its simple little
> stateful firewall, into the bit bucket it goes.  Have fun trying to pass
> SCTP or DCCP through that!
> 
I'll leave the rest of this alone, since its pretty obvious that no one is going
to break TCP for you, but just so that you're aware, The only reason you have to
use the 2-Wire gateway that AT&T provides is because there are no commercially
available routers that support the uplink interface (which I expect will change
eventually).  In the time being, if you want to use a different router, place
the RG in bridge mode by selecting a host as your DMZ device.  That will assign
the wan address to that connected device via DHCP and allow you to pass whatever
traffic you want through it.  I use it to pass SCTP and IPv6 traffice all the
time, works great.
Neil

