From: <Narendra_K@Dell.com>
Subject: Re: [PATCH V2] Use firmware provided index to register a network
 interface
Date: Thu, 7 Oct 2010 23:14:46 +0530
Message-ID: <20101007174435.GA2939@libnet-test.oslab.blr.amer.dell.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com>
 <20101007163113.GA14260@auslistsprd01.us.dell.com>
 <20101007164835.GA27339@kroah.com>
 <AANLkTinP5WPDPvk+kq8vsyP=xC9qcoe+c=1EBp0XJNPk@mail.gmail.com>
 <20101007171532.GA29857@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <kay.sievers@vrfy.org>, <Matt_Domsch@Dell.com>,
	<netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>, <Charles_Rose@Dell.com>
To: <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101007171532.GA29857@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2010 at 10:45:32PM +0530, Greg KH wrote:
>    On Thu, Oct 07, 2010 at 07:05:14PM +0200, Kay Sievers wrote:
>    > On Thu, Oct 7, 2010 at 18:48, Greg KH <greg@kroah.com> wrote:
>    > > On Thu, Oct 07, 2010 at 11:31:13AM -0500, Matt Domsch wrote:
>    > >> 1) SMBIOS type 41 method.  Windows does not use this today, and I
>    > >>    can't speak to their future plans.  Narendra's kernel patch does,
>    > >>    as has biosdevname, the udev helper we first wrote for this
>    > >>    purpose, for several years.
>    > >
>    > > Then stick with that udev helper please :)
>    >
>    > What about just exporting this information in sysfs, and not touch the
>    naming?
> 
>    I think this is now exported in userspace, right Narendra?
> 

Right. It is in the mainline kernel.
( commit 911e1c9b05a8e3559a7aa89083930700a0b9e7ee)

-- 
With regards,
Narendra K
