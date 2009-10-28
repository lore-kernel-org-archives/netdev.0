From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
 interfaces
Date: Wed, 28 Oct 2009 09:11:24 -0700
Message-ID: <20091028161124.GA2019@kroah.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
 <20091022063619.GB6321@ldl.fc.hp.com>
 <20091027205551.GA31963@auslistsprd01.us.dell.com>
 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
 <20091028130308.GA24611@auslistsprd01.us.dell.com>
 <20091028150913.GB3612@ldl.fc.hp.com>
 <5DDAB7BA7BDB58439DD0EED0B8E9A3AE02E827AF@ausx3mpc102.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dannf@hp.com, Matt_Domsch@Dell.com, kay.sievers@vrfy.org,
	linux-hotplug@vger.kernel.org, Narendra_K@Dell.com,
	netdev@vger.kernel.org, Charles_Rose@Dell.com,
	bhutchings@solarflare.com
To: Jordan_Hargrave@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE02E827AF@ausx3mpc102.aus.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Wed, Oct 28, 2009 at 11:09:36AM -0500, Jordan_Hargrave@Dell.com wrote:
> I was thinking, if we're not planning on use the chardev/kernel route.
> There already exists an ifindex file in /sys/class/net/XXX/ifindex.
> Should udev/helper be creating links to this, or is it better to keep
> everything under the /dev/ tree?  Using this method would require the
> patch to udev to handle renaming events.

Please never create symlinks out of /dev/ to /sys that doesn't make
sense at all and probably violates part of the LSB somewhere...

thanks,

greg k-h
