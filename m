From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [PATCH v3 0/2] net: add device groups
Date: Sat, 15 Jan 2011 18:45:07 +0200
Message-ID: <20110115164507.GE1240@cormyr>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
 <20110114080810.2f128064@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:60407 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752646Ab1AOQsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jan 2011 11:48:03 -0500
Content-Disposition: inline
In-Reply-To: <20110114080810.2f128064@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 08:08:10AM -0800, Stephen Hemminger wrote:
> On Fri, 14 Jan 2011 11:38:29 +0200
> Vlad Dogaru <ddvlad@rosedu.org> wrote:
> 
> > This patchset implements network device grouping and simple manipulation
> > of groups. Netlink has been updated to provide group information and
> > means of applying changes to members of a specific group via a single
> > message.
> > 
> > The patchset has a corresponding one for iproute2, which implements the
> > new functionality in userspace.
> 
> What about a read/write sysfs interface as well?
>   /sys/class/net/eth0/devgroup

Oops, I overlooked that, probably because I've been testing in a virtual
machine where the kernel has sysfs turned off -- less waiting for simple
tests.

> Not sure if numeric devgroup is best choice. Since this is more of
> a human interface parameter maybe it should be a string? Or have
> a translation in the utilities /etc/iproute2/devgroup?

I didn't know about /etc/iproute2. I could add the devgroup file as you
mention, seems like a good choice for userspace.

I'll update the patches with these, but it will probably take a few days,
I have a few exams next week :)

Thanks for the suggestions,
Vlad
