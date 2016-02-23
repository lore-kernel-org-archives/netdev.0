From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCHv2 09/10] rfkill: Userspace control for airplane mode
Date: Tue, 23 Feb 2016 21:55:14 +0100
Message-ID: <1456260914.9910.34.camel@sipsolutions.net>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
	 <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
	 <20160223204525.GC16961@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: Pavel Machek <pavel@ucw.cz>,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:34983 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755162AbcBWUzW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 15:55:22 -0500
In-Reply-To: <20160223204525.GC16961@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-23 at 21:45 +0100, Pavel Machek wrote:

> So... you add LED trigger to display the state of the airplane
> mode. Ok, why not.

Yes. However, consider that "the airplane mode" isn't a well-defined
concept; some systems may want to light up that LED even when wifi is
still enabled, since you're nowadays quite likely to be allowed to use
wifi (but not enable e.g. LTE) while in-flight.

> But now you add an way to override it? Why? If someone wants to
> change
> the led state, he can just change trigger to none, and then control
> the LED manually...

Yes, but now you've forced every application that wants to deal with
this to know about every single LED that might be used with this
trigger... that won't work for some generic userland tool that might
want to implement an "airplane-mode policy".

> BTW what happens when the device contains both radios controlled by
> kernel (wifi, bluetooth) and radios controlled by userspace (GSM
> modem)?

You'd better have the userspace to control the LED :)

johannes
