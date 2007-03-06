From: Greg KH <greg@kroah.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 16:37:15 -0800
Message-ID: <20070306003715.GA12566@kroah.com>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org> <20070305154609.GA3626@irc.pl> <20070305211425.GR16722@waste.org> <20070306002457.GA7078@brong.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com,
	akpm@osdl.org
To: Bron Gondwana <brong@fastmail.fm>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933678AbXCFAi7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070306002457.GA7078@brong.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 11:24:57AM +1100, Bron Gondwana wrote:
> On Mon, Mar 05, 2007 at 03:14:25PM -0600, Matt Mackall wrote:
> > On Mon, Mar 05, 2007 at 04:46:09PM +0100, Tomasz Torcz wrote:
> > > > That's not the point. The point is that Debian/unstable as of _this
> > > > morning_ doesn't work. For reference, I'm running both the latest
> > > > releases of both hal (0.5.8.1-6.1) and network-manager (0.6.4-6). And
> > > > there are people telling me I need a copy of HAL out of git that
> > > > hasn't even been released for Debian to package. Debian isn't the
> > > > problem here.
> > > 
> > >   hal 0.5.9-rc1 (released, not from git) should work. It will be
> > > problably released soon and picked by sane distributions. Debian is very
> > > irritating corner case.
> > 
> > Presumably the -rc1 stands for "release candidate". Which means "not
> > yet released". And when did it show up? 04-Mar-2007 at 18:31. That's
> > right, YESTERDAY. Almost a full month after Greg's commit.
> > 
> > For the last time, DEBIAN IS NOT THE PROBLEM.
> 
> Can I please second this (having been burned by hell that was udev of
> the 0.5ish era) - Greg, please try to make changes in a cross-compatible
> way so that versions of userspace and kernel are not so closely
> dependant on tracking each other.  The whole 2.6.8 -> 2.6.12 series of
> kernels and associated udevs are fraught with race conditions where
> upgrading one but not the other will leave your machine unbootable.

But I AM TRYING TO MAKE IT COMPATIBLE!!!

That's what that config option is there for.  If you happen to be
running a newer userspace, a different distro than what is in Debian
right now, or don't use HAL and Networkmanager, then disable that
option.  Then all of sysfs looks just like it used to, no user visble
changes at all.  It doesn't get any more compatible than that.

Again, I've pointed out distros that work just fine many times in this
thread...

It's been there since 2.6.20 I think, no one seemed to have noticed it
then for an odd reason...

And the default is enabled, you have to manually turn it off in order to
break your machine.

Again, how can I word this in a manner that would be sufficient to keep
this misunderstanding from happening again?

greg k-h
