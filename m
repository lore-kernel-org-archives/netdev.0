From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 18:20:44 +0100
Message-ID: <AANLkTikZ76VXdPf46FHxhCyf3n4rNZOQW4Rp2yUZWP2h@mail.gmail.com>
References: <4D79F068.2080009@linaro.org>
	<1300924878.2638.38.camel@bwh-desktop>
	<201103241413.54599.arnd@arndb.de>
	<201103241415.45115.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Steve Calfee <stevecalfee@gmail.com>,
	Michal Nazarewicz <mnazarewicz@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	broonie@opensource.wolfsonmicro.com,
	lkml <linux-kernel@vger.kernel.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Greg KH <greg@kroah.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, grant.likely@secretlab.ca,
	Linux USB list <linux-usb@vger.kernel.org>,
	andy.green@linaro.org, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	patches@linaro.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103241415.45115.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 24, 2011 at 2:15 PM, Arnd Bergmann <arnd@arndb.de> wrote:

>
> The approach taken here is to flag whether a device might be a
> point-to-point link with the new FLAG_PTP setting in the usbnet
> driver_info. A driver can set both FLAG_PTP and FLAG_ETHER if
> it is not sure (e.g. cdc_ether), or just one of the two.

> The usbnet framework only looks at the MAC address for device
> naming if both flags are set, otherwise it trusts the flag.

Should this paragraph above be a clue for the flag name?
Sorry for late comment, but having flag called FLAG_POINTTOPOINT is really
confusing. ptp, p2p terms are heavily used and will mislead folks.

Would it be better to call it something like IGNORE_MAC_ADDRESS if this is the
feature you are targeting?

/Alexey
