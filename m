From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 10:15:32 -0700
Message-ID: <20101007171532.GA29857@kroah.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com>
 <20101007163113.GA14260@auslistsprd01.us.dell.com>
 <20101007164835.GA27339@kroah.com>
 <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>, Narendra_K@dell.com,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Jordan_Hargrave@dell.com,
	Vijay_Nijhawan@dell.com, Charles_Rose@dell.com
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:49176 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210Ab0JGRPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 13:15:50 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 07:05:14PM +0200, Kay Sievers wrote:
> On Thu, Oct 7, 2010 at 18:48, Greg KH <greg@kroah.com> wrote:
> > On Thu, Oct 07, 2010 at 11:31:13AM -0500, Matt Domsch wrote:
> >> 1) SMBIOS type 41 method. =A0Windows does not use this today, and =
I
> >> =A0 =A0can't speak to their future plans. =A0Narendra's kernel pat=
ch does,
> >> =A0 =A0as has biosdevname, the udev helper we first wrote for this
> >> =A0 =A0purpose, for several years.
> >
> > Then stick with that udev helper please :)
>=20
> What about just exporting this information in sysfs, and not touch th=
e naming?

I think this is now exported in userspace, right Narendra?

> Anyway, I'm pretty sure all of this naming of onboard devices should
> happen only at install time, or from a system management tool and not
> at hotplug time.
>=20
> We should not get confused by the way the (very simple)
> automatic-rule-creater for persistent netdev naming in udev works.
> This is really just a tool for the common case, and works fine for th=
e
> majority of people.
>=20
> I'm not sure, if we should put all these special use cases in the
> hotplug path. I mean it's not that people add and remove 4 port
> network cards with special BIOS all the time, and expect proper namin=
g
> on the first bootup, right? The installer, or the system management
> tool could just create/edit udev rules to provide proper device namin=
g
> on whatever property is available at a specific hardware, be it the
> MAC address or some other persistent match?

I totally agree.

thanks,

greg k-h
