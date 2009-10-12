From: Narendra K <Narendra_K@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 13:07:58 -0500
Message-ID: <20091012180756.GA4602@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE58953F@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com,
	charles_rose@dell.com
To: notting@redhat.com, scott@ubuntu.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE58953F@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This makes them pretty comparable to LABELs on disks, and we have a 
> > /dev/disk/by-label
> > 
> > Remember that udev already supports symlink stacking, and priorities 
> > and such.
> > 
> > I don't think there's any danger of supporting a /dev/netdev/by-mac by
> 
> > default, it'll be a benefit to most and those who don't have unique 
> > MACs will just ignore it.
> 
> At the moment, we do not appear to get the proper change uevents from
> things like 'ip link set dev <foo> address <bar>', so we can't currently
> maintain these symlinks.
> 

I have observed that the kernel does generate a "move" event when
interfaces are renamed. Looks like udev at present doesn't handle this event, but i
suppose it could be extended to hanlde this event.

With regards,
Narendra K
