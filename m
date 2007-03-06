From: Bron Gondwana <brong@fastmail.fm>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Tue, 6 Mar 2007 11:24:57 +1100
Message-ID: <20070306002457.GA7078@brong.net>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org> <20070305154609.GA3626@irc.pl> <20070305211425.GR16722@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, greg@kroah.com,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com,
	akpm@osdl.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932601AbXCFAZR@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070305211425.GR16722@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 03:14:25PM -0600, Matt Mackall wrote:
> On Mon, Mar 05, 2007 at 04:46:09PM +0100, Tomasz Torcz wrote:
> > > That's not the point. The point is that Debian/unstable as of _this
> > > morning_ doesn't work. For reference, I'm running both the latest
> > > releases of both hal (0.5.8.1-6.1) and network-manager (0.6.4-6). And
> > > there are people telling me I need a copy of HAL out of git that
> > > hasn't even been released for Debian to package. Debian isn't the
> > > problem here.
> > 
> >   hal 0.5.9-rc1 (released, not from git) should work. It will be
> > problably released soon and picked by sane distributions. Debian is very
> > irritating corner case.
> 
> Presumably the -rc1 stands for "release candidate". Which means "not
> yet released". And when did it show up? 04-Mar-2007 at 18:31. That's
> right, YESTERDAY. Almost a full month after Greg's commit.
> 
> For the last time, DEBIAN IS NOT THE PROBLEM.

Can I please second this (having been burned by hell that was udev of
the 0.5ish era) - Greg, please try to make changes in a cross-compatible
way so that versions of userspace and kernel are not so closely
dependant on tracking each other.  The whole 2.6.8 -> 2.6.12 series of
kernels and associated udevs are fraught with race conditions where
upgrading one but not the other will leave your machine unbootable.

I read the "manifesto" for udev showing how crap devfs was, it was
broken, it could never be fixed etc - yet my experience was that devfs
systems "just worked"[tm] and udev was very dangerous.  My thinking is
going to be tarnished by that for a while and my mental image of udev
is "unreliable POS".  I'm hoping enough good experiences with udev might
make me feel less scared whenever I have to deal with it.

Similarly, I'm hoping I don't have to think "oh shit, will this break
boot" every time I upgrade either a kernel or hal version for the next
year, because it would really suck to do that all over again.  It
contributes to the meme that linux is unreliable and perpetually
unstable.

Regards,

Bron.
