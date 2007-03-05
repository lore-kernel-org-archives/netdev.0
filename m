From: Greg KH <greg@kroah.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Sun, 4 Mar 2007 23:02:48 -0800
Message-ID: <20070305070248.GA30699@kroah.com>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com, akpm@osdl.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:55180 "EHLO perch.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbXCEHEp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 02:04:45 -0500
Content-Disposition: inline
In-Reply-To: <20070305064229.GJ23311@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 12:42:29AM -0600, Matt Mackall wrote:
> On Sun, Mar 04, 2007 at 05:16:25PM -0800, Greg KH wrote:
> > On Sun, Mar 04, 2007 at 04:08:57PM -0600, Matt Mackall wrote:
> > > Recent kernels are having troubles with wireless for me. Two seemingly
> > > related problems:
> > > 
> > > a) NetworkManager seems oblivious to the existence of my IPW2200
> > > b) Manual iwconfig waits for 60s and then reports:
> > > 
> > > Error for wireless request "Set Encode" (8B2A) :
> > >     SET failed on device eth1 ; Operation not supported.
> > 
> > Do you have CONFIG_SYSFS_DEPRECATED enabled?  If not, please do as that
> > will keep you from having to change any userspace code.
> 
> No, it's disabled. Will test once I'm done tracking down the iwconfig
> problem. From the help text for SYSFS_DEPRECATED:
> 
>           If you are using a distro that was released in 2006 or
> 	  later, it should be safe to say N here.
> 
> If we need an as-yet-unreleased HAL without it, I would say the above
> should be changed to 2008 or so. If Debian actually cuts a release in
> the next few months, you might make that 2010.

Well, just because Debian has such a slow release cycle, should the rest
of the world be forced to follow suit?  :)

When I originally wrote that, I thought Debian would have already done
their release, my mistake...

thanks,

greg k-h
