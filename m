From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Tue, 23 Feb 2016 16:06:55 +0100
Message-ID: <3466361.DVRahbqhfF@wuerfel>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <2463567.tt0f0ingYr@wuerfel> <2927215.6IlWnjRTgT@fb07-iapwap2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Thierry Reding <thierry.reding@gmail.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Marc Dietrich <marvin24@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2927215.6IlWnjRTgT@fb07-iapwap2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 February 2016 14:42:55 Marc Dietrich wrote:
> Am Dienstag, 23. Februar 2016, 14:17:17 CET schrieb Arnd Bergmann:
> > On Tuesday 23 February 2016 11:38:52 Marc Dietrich wrote:
> > > Am Dienstag, 23. Februar 2016, 11:31:40 CET schrieb Arnd Bergmann:
> > Ah, so the problem of attaching DT properties to a USB device has recently
> > been solved, see subject "USB: core: let USB device know device node".
> > 
> > Would that work for you? With this, the USB driver can simply look at
> > the optional DT properties of the USB function to implement its rfkill
> > callbacks.
> 
> oh, that looks indeed interesting. The question is now if rfkill is a property 
> of a device or a subdevice itself. The latter one would only require addition 
> of device-tree instantiation of rfkill, while with the former one, the (or 
> all) usb driver(s) need to be modified to accept device tree properties, 
> especially gpios. The driver would then be responsible to add an rfkill 
> "device".
> 
> IMHO (and unfortunately), it's just a property (a way to specify the relevant 
> gpios), making the solution again hard to archive.

Does rfkill always have a separate device in the Linux driver model?

I would say that if we standardize on the property names, we can
have some generic helper code that does everything with one or
two function calls, similar to how we can read a mac address from
a DT node from ROM-less USB ethernet devices.

	Arnd
