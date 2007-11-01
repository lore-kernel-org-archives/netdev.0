From: David Brownell <david-b@pacbell.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function `usbnet_set_settings':
Date: Thu, 1 Nov 2007 16:32:18 -0700
Message-ID: <200711011632.18333.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <20071101141124.0cbe2897.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760730AbXKAXcd@vger.kernel.org>
In-Reply-To: <20071101141124.0cbe2897.randy.dunlap@oracle.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 November 2007, Randy Dunlap wrote:
> The MII functions aren't available unless NET_ETHERNET=3Dy.
> Howver, the MII functions aren't always needed...
>=20
> David, any ideas on this one?

It's been several years since I looked at this.  It
used to behave just fine.

Something must have changed in the not-too-distant
past to have broken this mechanism...


> =A0config USB_USBNET
> =A0 =A0 =A0 =A0 tristate "Multi-purpose USB Networking Framework"
> + =A0 =A0 =A0 depends on NET_ETHERNET if USB_USBNET_MII !=3D n
> =A0 =A0 =A0 =A0 select MII if USB_USBNET_MII !=3D n
>=20
> would be handy. =A0But invalid.
>=20
> Hm, wait. =A0Haven't we seen this before and decided that MII should
> be made more generally available? =A0I.e., not depend on NET_ETHERNET=
?

Some of us keep wanting to see "select" work properly,
not omitting dependencies...

Re interdependencies MII and NET_ETHERNET, I'll leave
that up to the netedev folk.

- Dave
