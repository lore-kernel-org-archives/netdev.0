From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode
Date: Tue, 23 Feb 2016 21:45:26 +0100
Message-ID: <20160223204525.GC16961@amd>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: =?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

[BTW you should probably Cc people responsible for LED subsystem...]

> Provide an interface for the airplane-mode indicator be controlled from
> userspace. User has to first acquire the control through
> RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole time
> it wants to be in control of the indicator. Closing the fd or using
> RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.
> 
> To change state of the indicator, the RFKILL_OP_AIRPLANE_MODE_CHANGE
> operation is used, passing the value on "struct rfkill_event.soft". If
> the caller has not acquired the airplane-mode control beforehand, the
> operation fails.

So... you add LED trigger to display the state of the airplane
mode. Ok, why not.

But now you add an way to override it? Why? If someone wants to change
the led state, he can just change trigger to none, and then control
the LED manually...

BTW what happens when the device contains both radios controlled by
kernel (wifi, bluetooth) and radios controlled by userspace (GSM
modem)?

Best regards,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
