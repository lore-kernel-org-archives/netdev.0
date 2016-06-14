From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 14 Jun 2016 09:40:17 -0700
Message-ID: <20160614164017.GB14477@kroah.com>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
 <20160611153921.GP2338@lunn.ch>
 <20160611.104226.1571085838142610714.davem@davemloft.net>
 <201606141828.10969@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
	mario_limonciello@dell.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:44012 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbcFNQk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 12:40:28 -0400
Content-Disposition: inline
In-Reply-To: <201606141828.10969@pali>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 06:28:10PM +0200, Pali Roh=E1r wrote:
> On Saturday 11 June 2016 19:42:26 David Miller wrote:
> > From: Andrew Lunn <andrew@lunn.ch>
> > Date: Sat, 11 Jun 2016 17:39:21 +0200
> >=20
> > > What is still open is do we want to accept it at all? Do we accep=
t
> > > the concept of putting the same MAC address on multiple interface=
s
> > > at hotplug time? Do we trust BIOS vendors to not keep changing
> > > DSDT property name, since it is not standardised?
> > >=20
> > > Do we want this at all should be decided by somebody more senior
> > > then those passing comments on the code.
> >=20
> > Indeed, I think the behavior of using the same MAC address on
> > multiple interfaces if we plug several of these in at once is not
> > good.
> >=20
> > We shouldn't behave this way just because the Microsoft driver does=
=2E
>=20
> I agree, but in some cases it is night mare for local admins when=20
> booting different OS cause changing MAC address on local network.
>=20
> Another similar situation: Imagine that you have two USB network card=
s=20
> and both have "burned" into their registers same MAC address. If you=20
> connect both those USB network cards, linux kernel bind appropriate=20
> driver which read MAC address for both those cards. But those address=
es=20
> are same. What will linux kernel do in this case?

If you can find such a broken USB device, try it and see :)

(hint, might be hard to find, I've never seen such a device before.)

I don't see how that pertains to this issue, sorry, how does broken USB
hardware compare to a working Dell device?

thanks,

greg k-h
