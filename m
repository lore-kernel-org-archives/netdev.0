From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Remove Prism II support from Orinoco
Date: Mon, 12 Jun 2006 21:20:48 -0700
Message-ID: <20060613042048.GA14824@shell0.pdx.osdl.net>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity> <20060612152434.GA14851@tuxdriver.com> <4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29098 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932819AbWFMEUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 00:20:52 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Content-Disposition: inline
In-Reply-To: <4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/06 17:10 -0700, Jesse Brandeburg wrote:
> On 6/12/06, John W. Linville <linville@tuxdriver.com> wrote:
> >On Mon, Jun 12, 2006 at 01:49:54AM +0300, Faidon Liambotis wrote:
> >
> >> Having two drivers supporting the same set of hardware seems pretty
> >> pointless to me. Plus, it confuses hotplugging/automatic detection.
> >
> >This subject comes-up from time to time.  In fact, I'm pretty sure
> >it came-up very recently w.r.t. orinoco and hostap.
> >
> >The consensus seems to be that drivers should have IDs for all devices
> >they support, even if that means that some devices are supported by
> >multiple drivers.  This leaves the choice of which driver to use in
> >the hands of the user and/or distro.
> 
> my problem is that for my prism 2 adapter both drivers are loaded at
> which point neither of them works.  I'm running FC5, and i have to
> keep removing the orinoco*.ko files to keep them from loading, so I'm
> all for this patch.
> 

use blacklist in module config to block one.
Just put in /etc/modprobe.conf

blacklist orinoco
