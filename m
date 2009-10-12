From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 11:15:46 -0700
Message-ID: <20091012181546.GA9236@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
 <20091009210909.GA9836@auslistsprd01.us.dell.com>
 <20091009194401.036da080@nehalam>
 <20091010044056.GA5350@mock.linuxdev.us.dell.com>
 <20091010052308.GA12458@kroah.com>
 <20091012174528.GB22736@nostromo.devel.redhat.com>
 <20091012175508.GA10946@kroah.com>
 <20091012180740.GE22736@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Bill Nottingham <notting@redhat.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091012180740.GE22736@nostromo.devel.redhat.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2009 at 02:07:42PM -0400, Bill Nottingham wrote:
> Greg KH (greg@kroah.com) said: 
> > > No, it's not solved. Even if you have persistent names once you install,
> > > if you ever re-image, you're likely to get *different* persistent names;
> > > the first load will always be non-detmerministic.
> > > 
> > > The only way around this would be to have some sort of screen like:
> > > 
> > >   Would you like your network devices to be enumerated by
> > > 
> > >   [ ] MAC address
> > >   [ ] PCI device order
> > >   [ ] Driver name
> > >   [ ] Other
> > 
> > [ ] PCI slot name
> > 
> > That's one that modern systems are now reporting, and should solve
> > Matt's problem as well, right?
> 
> ... maybe. On my laptop, the first 'slot' enumerated appears to be
> the cardbus bridge, before the on-board ethernet. And on the desktop
> next to me, the slot driver shows nothing.

On servers, where this matters (multiple ethernet pci devices), this
should all be present if the manufacturer wants it to be, as it is just
an ACPI table entry.

> > And I don't see how Matt's proposed patch helps resolve this type of
> > issue any better than what we currently have today, do you?
> 
> It allows multiple addressing schemes to be active at once, which
> can allow the admin to choose post-install without making an
> active choice at installation. This is an improvement, even if
> it doesn't solve the world.

But these different names can not be used by the networking stack, or in
scripts, as others have pointed out.  Which seems to be the big problem
here.

thanks,

greg k-h
