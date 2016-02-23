From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Tue, 23 Feb 2016 11:31:40 +0100
Message-ID: <3086257.esvHq8Yk9N@wuerfel>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <1455825889.2084.16.camel@sipsolutions.net> <5438459.Mb6Ga2Xhyq@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Thierry Reding <thierry.reding@gmail.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Marc Dietrich <marvin24@gmx.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5438459.Mb6Ga2Xhyq@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 February 2016 11:15:31 Arnd Bergmann wrote:
> On Thursday 18 February 2016 21:04:49 Johannes Berg wrote:
> > On Tue, 2016-01-26 at 09:42 +0100, Johannes Berg wrote:

> Just for my curiosity: what is the difference between a rfkill-gpio
> device and a gpio-keys device with a KEY_RFKILL code?
> 
> arch/arm/boot/dts/bcm4708-netgear-r6250.dts and others seem to
> do the second approach in DT so they don't need to create the
> platform device.

I found the answer now (after discussing on IRC): just
for reference: KEY_RFKILL is for sending the event to the kernel
when a user presses the gpio butting, this rfkill-gpio turns
the devices on or off when after an RFKILL event is received.

	Arnd
