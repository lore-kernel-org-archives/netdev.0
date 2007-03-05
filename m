From: Matt Mackall <mpm@selenic.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 01:13:26 -0600
Message-ID: <20070305071325.GK23311@waste.org>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:49319 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967AbXCEHZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 02:25:58 -0500
Content-Disposition: inline
In-Reply-To: <20070305070248.GA30699@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 04, 2007 at 11:02:48PM -0800, Greg KH wrote:
> On Mon, Mar 05, 2007 at 12:42:29AM -0600, Matt Mackall wrote:
> > On Sun, Mar 04, 2007 at 05:16:25PM -0800, Greg KH wrote:
> > > On Sun, Mar 04, 2007 at 04:08:57PM -0600, Matt Mackall wrote:
> > > > Recent kernels are having troubles with wireless for me. Two seemingly
> > > > related problems:
> > > > 
> > > > a) NetworkManager seems oblivious to the existence of my IPW2200
> > > > b) Manual iwconfig waits for 60s and then reports:
> > > > 
> > > > Error for wireless request "Set Encode" (8B2A) :
> > > >     SET failed on device eth1 ; Operation not supported.
> > > 
> > > Do you have CONFIG_SYSFS_DEPRECATED enabled?  If not, please do as that
> > > will keep you from having to change any userspace code.
> > 
> > No, it's disabled. Will test once I'm done tracking down the iwconfig
> > problem. From the help text for SYSFS_DEPRECATED:
> > 
> >           If you are using a distro that was released in 2006 or
> > 	  later, it should be safe to say N here.
> > 
> > If we need an as-yet-unreleased HAL without it, I would say the above
> > should be changed to 2008 or so. If Debian actually cuts a release in
> > the next few months, you might make that 2010.
> 
> Well, just because Debian has such a slow release cycle, should the rest
> of the world be forced to follow suit?  :)
> 
> When I originally wrote that, I thought Debian would have already done
> their release, my mistake...

That's not the point. The point is that Debian/unstable as of _this
morning_ doesn't work. For reference, I'm running both the latest
releases of both hal (0.5.8.1-6.1) and network-manager (0.6.4-6). And
there are people telling me I need a copy of HAL out of git that
hasn't even been released for Debian to package. Debian isn't the
problem here.

If it is indeed the case that HAL needs to be upgraded here, the clock
on deprecating these features can't even start counting until a usable
HAL version is released. And then you need to give it at least a year
after that before you can start recommending people disable it.

-- 
Mathematics is the supreme nostalgia of our time.
