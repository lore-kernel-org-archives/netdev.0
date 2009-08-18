From: Tim Bird <tim.bird@am.sony.com>
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 18:40:48 -0700
Message-ID: <4A8A06A0.2070402@am.sony.com>
References: <4A89DB15.6060101@am.sony.com>	<20090817.180323.253692704.davem@davemloft.net>	<4A8A02CA.7040305@am.sony.com> <20090817.182754.50348941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20090817.182754.50348941.davem@davemloft.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Tim Bird <tim.bird@am.sony.com>
> Date: Mon, 17 Aug 2009 18:24:26 -0700
>
>> David Miller wrote:
>>> I have card/switch combinations that take up to 10 seconds to
>>> negotiate a proper link.
>> What types of delays are these timeouts supposed to
>> cover?
>
> The problem is that if you don't first give at least some time for the
> link to come up, the remaining time it takes the link to come up will
> end up chewing into the actual bootp/dhcp protocol timeouts.  And
> that's what we're trying to avoid.

What link?  I'm not that familiar with networking.

Assuming I'm using ethernet, what link needs to come up?
Is this something to do with power propagation to the
physical wire?  Is there some MAC layer negotiation
between the card and the switch?  Is it the time for
the switch to do speed detection?

And, can any of this be more accurately determined
or guessed-at with knowledge of the onboard hardware?
Or is it dependent on external conditions?

Where would be a good place to find out more about
startup delays for networking chips and/or protocols?

Our usual solution is to kick the can down the road
and let user-space initialize anything that takes a long
time,  while we do other stuff like focus the camera or display
the TV picture.  It would be good to learn more about
this.
 -- Tim

=============================
Tim Bird
Architecture Group Chair, CE Linux Forum
Senior Staff Engineer, Sony Corporation of America
=============================
