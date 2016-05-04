From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RESEND PATCH 1/3] rfkill: Create "rfkill-airplane-mode" LED
 trigger
Date: Wed, 4 May 2016 09:29:36 +0200
Message-ID: <20160504072936.GB17045@amd>
References: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
 <1462199948-6424-2-git-send-email-jprvita@endlessm.com>
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
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462199948-6424-2-git-send-email-jprvita@endlessm.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> This creates a new LED trigger to be used by platform drivers as a
> default trigger for airplane-mode indicator LEDs.
> 
> By default this trigger will fire when RFKILL_OP_CHANGE_ALL is called
> for all types (RFKILL_TYPE_ALL), setting the LED brightness to LED_FULL
> when the changing the state to blocked, and to LED_OFF when the changing
> the state to unblocked. In the future there will be a mechanism for
> userspace to override the default policy, so it can implement its
> own.

If userspace wants to control the manually, it can do just that --
control it manually. There should not be a need to "override the
default policy".
								Pavel
								
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
