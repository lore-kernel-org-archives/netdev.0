From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 09:27:03 -0700
Message-ID: <20091010162703.GB30354@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <921ca19c0910100117xdb94fcbo43e9b8ffaf4db997@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Sujit K M <sjt.kar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:45299 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761976AbZJJQ2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 12:28:01 -0400
Content-Disposition: inline
In-Reply-To: <921ca19c0910100117xdb94fcbo43e9b8ffaf4db997@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 10, 2009 at 01:47:39PM +0530, Sujit K M wrote:
> Greg,
> 
> 
> > No, the hardware changes the enumeration order, it places _no_
> > guarantees on what order stuff will be found in. ?So this is not the
> > kernel changing, just to be clear.
> > Again, I have a machine here that likes to reorder PCI devices every 4th
> > or so boot times, and that's fine according to the PCI spec. ?Yeah, it's
> > a crappy BIOS, but the manufacturer rightly pointed out that it is not
> > in violation of anything.
> >
> 
> I think the open call should be implemented then. By the patch very little
> knowledge is being shared on type of network implementation it is trying to
> do.

What would open() accomplish?  What good would the file descriptor be?
What could you use it for?

> Also it is messing with core datastructure and procedures. This seems
> to be simplified by changing implementing the other operations like poll().

I don't understand.

> > That is why all distros name network devices based on the only
> > deterministic thing they have today, the MAC address. ?I still fail to
> > see why you do not like this solution, it is honestly the only way to
> > properly name network devices in a sane manner.
> 
> This is feature that needs to be implemented. As per the rules followed.

This feature is already implemented today, all distros have it.

> > All distros also provide a way to easily rename the network devices, to
> > place a specific name on a specific MAC address, so again, this should
> > all be solved already.
> >
> > No matter how badly your BIOS teams mess up the PCI enumeration order :)
> 
> This is an problem, But I think this can be solved by implementing some of the
> routines in the network device.

I don't, see the rules that your distro ships today for persistant
network devices, it's already there, no need to change the kernel at
all.

thanks,

greg k-h
