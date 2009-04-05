From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] NET/r8169: Rework suspend and resume
Date: Sun, 5 Apr 2009 23:59:31 +0200
Message-ID: <200904052359.31629.rjw@sisk.pl>
References: <200904052040.04752.rjw@sisk.pl> <20090405223318.5a494e4e@neptune.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>
To: Bruno =?iso-8859-1?q?Pr=E9mont?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41621 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbZDEV7f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 17:59:35 -0400
In-Reply-To: <20090405223318.5a494e4e@neptune.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 April 2009, Bruno Pr=E9mont wrote:
> On Sun, 05 April 2009 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> >=20
> > The recent changes of the PCI PM core allow us to simplify the
> > suspend and resume handling in a number of device drivers, since th=
ey
> > don't need to carry out the general PCI PM operations, such as
> > changing the power state of the device, during suspend and resume a=
ny
> > more.
> >=20
> > Simplify the suspend and resume callbacks of r8169 using the
> > observation that the PCI PM core can take care of some operations
> > carried out by the driver.
> >=20
> > Additionally, make the shutdown callback of r8169 only put the devi=
ce
> > into a low power state if the system is going to be powered off
> > (kexec is known to have problems with network adapters that are put
> > into low power states on shutdown).
> >=20
> > This patch has been tested on MSI Wind U100.
>=20
> Tested against 2.6.29.1 on my Commell LE-365 and suspend (S3) + WoL
> still works as expected.
>=20
> 02:08.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
>                      RTL-8169 Gigabit Ethernet [10ec:8169] (rev 10)

Thanks for testing!

Best,
Rafael
