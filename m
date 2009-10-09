From: Greg KH <greg@kroah.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 9 Oct 2009 09:36:13 -0700
Message-ID: <20091009163613.GA3414@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	matt_domsch@dell.com, jordan_hargrave@dell.com
To: Narendra K <narendra_k@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091009140000.GA18765@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2009 at 09:00:01AM -0500, Narendra K wrote:
> On Fri, Oct 09, 2009 at 07:12:07PM +0530, K, Narendra wrote:
> > > example udev config:
> > > SUBSYSTEM=="net",
> > SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> > 
> > work as well.  But coupling the ifindex to the MAC address like this
> > doesn't work.  (In general, coupling any two unrelated attributes when
> > trying to do persistent names doesn't work.)
> > 
> Attaching the latest patch incorporating review comments.
> 
> By creating character devices for every network device, we can use
> udev to maintain alternate naming policies for devices, including
> additional names for the same device, without interfering with the
> name that the kernel assigns a device.
> 
> This is conditionalized on CONFIG_NET_CDEV.  If enabled (the default),
> device nodes will automatically be created in /dev/netdev/ for each
> network device.  (/dev/net/ is already populated by the tun device.)
> 
> These device nodes are not functional at the moment - open() returns
> -ENOSYS.  Their only purpose is to provide userspace with a kernel
> name to ifindex mapping, in a form that udev can easily manage.

How does this patch work with the network namespace functionality?

thanks,

greg k-h
