From: Narendra K <Narendra_K@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Wed, 28 Oct 2009 08:06:00 -0500
Message-ID: <20091028130558.GA21403@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE58964E@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	matt_domsch@dell.com, jordan_hargrave@dell.com,
	rose_charles@dell.com
To: notting@redhat.com, scott@ubuntu.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE58964E@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2009 at 06:21:49PM +0530, K, Narendra wrote:
> > At the moment, we do not appear to get the proper change uevents from 
> > things like 'ip link set dev <foo> address <bar>', so we can't 
> > currently maintain these symlinks.
> > 
> 
> I have observed that the kernel does generate a "move" event when
> interfaces are renamed. Looks like udev at present doesn't handle this
> event, but i suppose it could be extended to hanlde this event.
> 

With the patch "[PATCH]udev:Extend udev to support move events"
(http://marc.info/?l=linux-hotplug&m=125673399217656&w=2) udev would be
able to handle "move" events that are generated when interfaces are
renamed by commands like nameif. And we can maintain the symlinks by
having rules to handle this move event.

With regards,
Narendra K
