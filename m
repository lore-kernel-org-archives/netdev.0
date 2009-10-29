From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
 interfaces
Date: Thu, 29 Oct 2009 07:25:54 -0700
Message-ID: <20091029142554.GA16869@kroah.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
 <20091022063619.GB6321@ldl.fc.hp.com>
 <20091027205551.GA31963@auslistsprd01.us.dell.com>
 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
 <20091029131125.GA13809@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>, dann frazier <dannf@hp.com>,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	netdev@vger.kernel.org, Jordan_Hargrave@dell.com,
	Charles_Rose@dell.com, Ben Hutchings <bhutchings@solarflare.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091029131125.GA13809@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 29, 2009 at 08:11:25AM -0500, Matt Domsch wrote:
> Netdev team - are you in agreement that having multiple names to
> address the same netdevice is a worthwhile thing to add, to allow a
> variety of naming schemes to exist simultaneously?  If not, this whole
> discussion will be moot, and my basic problem, that the ethX naming
> convention is nondeterministic, but we need determinism, remains
> unresolved.

I'm still totally confused as to why you think this.  What is wrong with
what we do today, which is name network devices in a deterministic
manner by their MAC in userspace?  That name goes into the kernel, and
everyone uses the same name and is happy.

If you don't like naming by MAC, then pick some other deterministic
naming scheme that works for your hardware and write udev rules for it.

You could easily name them in a way that could keep the lowest number
(eth0) for the lowest PCI id if you so desired and your BIOS guaranteed
it.

This way the kernel has only one name, and so does userspace, and
everyone is happy.

thanks,

greg k-h
