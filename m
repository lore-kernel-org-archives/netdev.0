From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Fri, 25 Mar 2011 17:26:31 +0100
Message-ID: <AANLkTikEJi7bg5GG3Ero_Poe9F6WiKo8rW+Y1KtxhQ4B@mail.gmail.com>
References: <4D79F068.2080009@linaro.org>
	<201103241415.45115.arnd@arndb.de>
	<AANLkTikZ76VXdPf46FHxhCyf3n4rNZOQW4Rp2yUZWP2h@mail.gmail.com>
	<201103251257.32714.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
In-Reply-To: <201103251257.32714.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2011 at 12:57 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>
> That would be a different way of looking at it. =A0FLAG_POINTTOPOINT
> describes what the device is (a USB cable connecting two hosts), and
> that flag can be used for various things, where the only thing
> we currently do is the netif naming.
>

=46or example, cdc_ether and cdc-ncm drivers can be used in different u=
se cases:
a) when device terminates the IP traffic
or
b) where device is a wireless router.

In both cases ethernet frames are sent over usb cable and terminated
in device (eth header stripped), so it is point-to-point link for ether=
net, but
looking from IP layer is not p2p link for case b).

Please, explain, based on your idea, do we set this flag in both cases =
or not?
Do you want to use the same netif name for both use cases described abo=
ve?

/alexey
