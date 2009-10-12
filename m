From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 10:55:08 -0700
Message-ID: <20091012175508.GA10946@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091009210909.GA9836@auslistsprd01.us.dell.com>
 <20091009194401.036da080@nehalam>
 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
 <20091010052308.GA12458@kroah.com>
 <20091012174528.GB22736@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Bill Nottingham <notting@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:35734 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933021AbZJLR6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Oct 2009 13:58:50 -0400
Content-Disposition: inline
In-Reply-To: <20091012174528.GB22736@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2009 at 01:45:28PM -0400, Bill Nottingham wrote:
> Greg KH (greg@kroah.com) said: 
> > > Today, port naming is completely nondeterministic.  If you have but
> > > one NIC, there are few chances to get the name wrong (it'll be eth0).
> > > If you have >1 NIC, chances increase to get it wrong.
> > 
> > That is why all distros name network devices based on the only
> > deterministic thing they have today, the MAC address.  I still fail to
> > see why you do not like this solution, it is honestly the only way to
> > properly name network devices in a sane manner.
> > 
> > All distros also provide a way to easily rename the network devices, to
> > place a specific name on a specific MAC address, so again, this should
> > all be solved already.
> 
> No, it's not solved. Even if you have persistent names once you install,
> if you ever re-image, you're likely to get *different* persistent names;
> the first load will always be non-detmerministic.
> 
> The only way around this would be to have some sort of screen like:
> 
>   Would you like your network devices to be enumerated by
> 
>   [ ] MAC address
>   [ ] PCI device order
>   [ ] Driver name
>   [ ] Other

[ ] PCI slot name

That's one that modern systems are now reporting, and should solve
Matt's problem as well, right?

> which is just all sorts of fail in and of itself. Especially since
> once you get to the point where you can coherently ask this in a
> native installer, the drivers have already loaded.

No, the driver load order doesn't determine this, you need the drivers
loaded first before you can rename anything :)

And I don't see how Matt's proposed patch helps resolve this type of
issue any better than what we currently have today, do you?

thanks,

greg k-h
