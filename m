From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Tue, 22 Mar 2016 16:29:12 +0100
Message-ID: <1458660552.1990.13.camel@suse.com>
References: <Pine.LNX.4.44L0.1603221111040.1793-100000@iolanthe.rowland.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1603221111040.1793-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-03-22 at 11:13 -0400, Alan Stern wrote:
> > Indeed. In that case the point is moot. But it is correct to ask
> > the core whether the device is autosuspended at that point rather
> > than keep a private flag if you can.
> 
> That's why we have pm_runtime_status_suspended().

I guess we are in violent agreement though we were unaware of being
in that state.

	Regards
		Oliver
