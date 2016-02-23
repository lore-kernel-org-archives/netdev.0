From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Tue, 23 Feb 2016 11:38:52 +0100
Message-ID: <4048115.S0MS1KQXCA@fb07-iapwap2>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <5438459.Mb6Ga2Xhyq@wuerfel> <3086257.esvHq8Yk9N@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart28007355.n5LOP7PcBk"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Thierry Reding <thierry.reding@gmail.com>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org,
	Alexandre Courbot <gnurou@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3086257.esvHq8Yk9N@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart28007355.n5LOP7PcBk
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Am Dienstag, 23. Februar 2016, 11:31:40 CET schrieb Arnd Bergmann:
> On Tuesday 23 February 2016 11:15:31 Arnd Bergmann wrote:
> > On Thursday 18 February 2016 21:04:49 Johannes Berg wrote:
> > > On Tue, 2016-01-26 at 09:42 +0100, Johannes Berg wrote:
> > Just for my curiosity: what is the difference between a rfkill-gpio
> > device and a gpio-keys device with a KEY_RFKILL code?
> > 
> > arch/arm/boot/dts/bcm4708-netgear-r6250.dts and others seem to
> > do the second approach in DT so they don't need to create the
> > platform device.
> 
> I found the answer now (after discussing on IRC): just
> for reference: KEY_RFKILL is for sending the event to the kernel
> when a user presses the gpio butting, this rfkill-gpio turns
> the devices on or off when after an RFKILL event is received.

yes, paz00 has no hw key. rfkill is triggered via software (rfkill) only. The 
problem in the past was how to describe such a device in the device tree. 

Strictly speaking, there is no rfkill device hardware (just an interface). The 
only hardware that exists is in our case is connected to a hard wired usb bus 
(wifi dongle), which makes it complicated to attach a DT property or subdevice 
to it. And a standalone device-tree entry for a non hardware device was 
rejected in the past.

Marc

--nextPart28007355.n5LOP7PcBk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJWzDa8AAoJEKyeR39HFBtoNyUIAJbJvrPvhNYucVvuX7+lVt2J
3yn/jFVWk1++pJDqn2pbcVxrnRZ1X9/Y8rwTnFdHBeTppQ71fwpPFs8aJxemKxPG
NRTVslnJzdT8sEKgdAa4Xlw4f3sVOOYhQOeJVT1yqXyn3N3HRKEd39PwnsePeZFE
h4/EyrAinnN8wOcd5eUkDyGh6q8PRceYfiD5ApH6InGooi0gqY7IsQqnOZV6VZWu
TmZEFW8QSbrwxBTJHMrwnelagvAvLXztfuoO44IEbdo3XbH9gC2vau7PBbMF2WhB
E1ZsZ9FIO3amiyrV6hTcb8R0RnjNeqebXauLEhmqeS1RFtPOedMUpJLgh6VKIlQ=
=cqhn
-----END PGP SIGNATURE-----

--nextPart28007355.n5LOP7PcBk--
