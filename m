From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH V2] Use firmware provided index to register a network interface
Date: Thu, 7 Oct 2010 19:05:14 +0200
Message-ID: <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com> <20101007163113.GA14260@auslistsprd01.us.dell.com>
 <20101007164835.GA27339@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Domsch <Matt_Domsch@dell.com>, Narendra_K@dell.com,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, Jordan_Hargrave@dell.com,
	Vijay_Nijhawan@dell.com, Charles_Rose@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20101007164835.GA27339@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 7, 2010 at 18:48, Greg KH <greg@kroah.com> wrote:
> On Thu, Oct 07, 2010 at 11:31:13AM -0500, Matt Domsch wrote:
>> 1) SMBIOS type 41 method. =C2=A0Windows does not use this today, and=
 I
>> =C2=A0 =C2=A0can't speak to their future plans. =C2=A0Narendra's ker=
nel patch does,
>> =C2=A0 =C2=A0as has biosdevname, the udev helper we first wrote for =
this
>> =C2=A0 =C2=A0purpose, for several years.
>
> Then stick with that udev helper please :)

What about just exporting this information in sysfs, and not touch the =
naming?

Anyway, I'm pretty sure all of this naming of onboard devices should
happen only at install time, or from a system management tool and not
at hotplug time.

We should not get confused by the way the (very simple)
automatic-rule-creater for persistent netdev naming in udev works.
This is really just a tool for the common case, and works fine for the
majority of people.

I'm not sure, if we should put all these special use cases in the
hotplug path. I mean it's not that people add and remove 4 port
network cards with special BIOS all the time, and expect proper naming
on the first bootup, right? The installer, or the system management
tool could just create/edit udev rules to provide proper device naming
on whatever property is available at a specific hardware, be it the
MAC address or some other persistent match?

Kay
