From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Tue, 22 Mar 2016 15:28:23 +0100
Message-ID: <1458656903.1990.12.camel@suse.com>
References: <Pine.LNX.4.44L0.1603221014500.1793-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	Woojung Huh <woojung.huh@microchip.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1603221014500.1793-100000@iolanthe.rowland.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-22 at 10:21 -0400, Alan Stern wrote:
> I don't see any point in resuming the device just in order to collect 
> operating statistics.  If it was already suspended then it wasn't 
> operating, so there will be no statistics to collect.

Indeed. In that case the point is moot. But it is correct to ask
the core whether the device is autosuspended at that point rather
than keep a private flag if you can.

All that is relevant only if the upper layers ask for information
that the driver cannot provide without resuming the device.
Those are fundamentally different issues.

	Regards
		Oliver


