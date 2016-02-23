From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode
Date: Tue, 23 Feb 2016 22:45:02 +0100
Message-ID: <20160223214501.GA22501@amd>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
 <20160223204525.GC16961@amd>
 <1456260914.9910.34.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456260914.9910.34.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 2016-02-23 21:55:14, Johannes Berg wrote:
> On Tue, 2016-02-23 at 21:45 +0100, Pavel Machek wrote:
> 
> > So... you add LED trigger to display the state of the airplane
> > mode. Ok, why not.
> 
> Yes. However, consider that "the airplane mode" isn't a well-defined
> concept; some systems may want to light up that LED even when wifi is
> still enabled, since you're nowadays quite likely to be allowed to use
> wifi (but not enable e.g. LTE) while in-flight.

Well "the airplane mode" is well defined. It means no intentional
transmitting at radio frequencies.

The fact that you are allowed to use WIFI on certain flights does not
change anything.

> > But now you add an way to override it? Why? If someone wants to
> > change
> > the led state, he can just change trigger to none, and then control
> > the LED manually...
> 
> Yes, but now you've forced every application that wants to deal with
> this to know about every single LED that might be used with this
> trigger... that won't work for some generic userland tool that might
> want to implement an "airplane-mode policy".

I see that "airplane mode" trigger might be a tiny bit
useful... dunno, for a LED near the airplane mode switch, when vendor
replaced hardware toggle with a key. But policy should have nothing to
do with that. If you argue additional "policy daemon" is needed for
that... forget it, that's overdesigned.

(Besides, finding all LEDs with given trigger is trivial
operation. Besides... there should never be more than one).

> > BTW what happens when the device contains both radios controlled by
> > kernel (wifi, bluetooth) and radios controlled by userspace (GSM
> > modem)?
> 
> You'd better have the userspace to control the LED :)

Yes, so lets forget that and no additional triggers? Good ;-).
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
