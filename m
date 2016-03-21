From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 18:34:30 +0100
Message-ID: <1458581670.9609.5.camel@suse.com>
References: <Pine.LNX.4.44L0.1603211049050.1708-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Woojung Huh <woojung.huh@microchip.com>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1603211049050.1708-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-03-21 at 10:57 -0400, Alan Stern wrote:

> One possible solution is to export a sysfs parameter to prevent 
> statistics collection (or more generally, to change the interval at 
> which it occurs).

Surely, not performing a task can hardly be beaten in terms of power
consumption. That is not meant to be flippant, but I think these
issues are orthogonal. The question of how much to do doesn't
solve the question of doing efficiently what we do.

> But checking the runtime_auto flag is probably not a great idea.  Even
> if it isn't set, collecting statistics is likely to wait up a device
> that otherwise would have remained suspended.
> 
> Perhaps the best solution is to collect the statistics only when the 
> device is not suspended or is about to suspend.

If we know when the next activity will come, why not pass this
information down?

	Regards
		Oliver
