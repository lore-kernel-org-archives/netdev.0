From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 22:23:08 -0700
Message-ID: <20091010052308.GA12458@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	jordan_hargrave@dell.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091010044056.GA5350@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2009 at 11:40:57PM -0500, Matt Domsch wrote:
> The fundamental roadblock to this is that enumeration != naming,
> except that it is for network devices, and we keep changing the
> enumeration order.

No, the hardware changes the enumeration order, it places _no_
guarantees on what order stuff will be found in.  So this is not the
kernel changing, just to be clear.

Again, I have a machine here that likes to reorder PCI devices every 4th
or so boot times, and that's fine according to the PCI spec.  Yeah, it's
a crappy BIOS, but the manufacturer rightly pointed out that it is not
in violation of anything.

> Today, port naming is completely nondeterministic.  If you have but
> one NIC, there are few chances to get the name wrong (it'll be eth0).
> If you have >1 NIC, chances increase to get it wrong.

That is why all distros name network devices based on the only
deterministic thing they have today, the MAC address.  I still fail to
see why you do not like this solution, it is honestly the only way to
properly name network devices in a sane manner.

All distros also provide a way to easily rename the network devices, to
place a specific name on a specific MAC address, so again, this should
all be solved already.

No matter how badly your BIOS teams mess up the PCI enumeration order :)

thanks,

greg k-h
