From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [2.6.21 patch] unconditionally enable SYSFS_DEPRECATED
Date: Mon, 5 Mar 2007 20:03:50 -0800
Message-ID: <20070306040350.GA25783@kroah.com>
References: <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org> <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org> <20070305185813.GA31465@kroah.com> <20070305234052.GR3441@stusta.de> <20070306000722.GA11436@kroah.com> <20070306013020.GN23311@waste.org> <20070306024850.GA24477@kroah.com> <20070306033947.GQ23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070306033947.GQ23311-1tnLUEbcrg3YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 09:39:47PM -0600, Matt Mackall wrote:
> On Mon, Mar 05, 2007 at 06:48:50PM -0800, Greg KH wrote:
> > If so, can you disable the option and strace it to see what program is
> > trying to access what?  That will put the
> > HAL/NetworkManager/libsysfs/distro script finger pointing to rest pretty
> > quickly :)
> 
> Ok, I've got straces of both good and bad (>5M each). Filtered out
> random pointer values and the like, diffed, and filtered for /sys/,
> and the result's still 1.5M. What should I be looking for?

Failures when trying to read from /sys/class/net/

Or opening the directory and iterating over the subdirs in there.  Or
something like that.

But the /sys/class/net/ stuff should hopefully help narrow it down.

thanks,

greg k-h
