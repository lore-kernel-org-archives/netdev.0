From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 15:42:35 -0500
Message-ID: <20101007204235.GB18035@pws490.domsch.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com>
 <20101007163113.GA14260@auslistsprd01.us.dell.com>
 <20101007164835.GA27339@kroah.com>
 <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, "K, Narendra" <Narendra_K@Dell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2010 at 10:05:14AM -0700, Kay Sievers wrote:
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

The config tools all take a netdevice name as their argument.  What
would it look like then?


$ ifconfig $(netdevname 'Embedded NIC 1')

repeat for each tool that's called?  This is similar to what we
proposed with the userspace patch and libnetdevname, so the lookup can
happen inside each app, rather than the system admin having to do the
translation themselves.  That was rejected too...

otherwise, it's up to a human to do the translation in their head,
which isn't script-friendly.

-Matt

--
Matt Domsch
Technology Strategist
Dell | Office of the CTO
