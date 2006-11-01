From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Wed, 01 Nov 2006 10:31:19 -0800
Message-ID: <4548E7F7.7030100@linux.intel.com>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:36213 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1752279AbWKASa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 13:30:57 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061101142022.GC21668@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Wed, Nov 01, 2006 at 11:28:05AM +0100, Jiri Benc wrote:
>> On Wed, 25 Oct 2006 22:15:23 -0700, Simon Barber wrote:
>>> Re: registering as a real protocol - yes this I have been going on about
>>> for a while. This needs a few changes in how things work:
>>>
>>> 1. Register as a real protocol.
>>> 2. Change drivers to use netif_rx to receive frames (will also be more
>>> efficient)
>> This is something I really want too.
> 
> I see Simon's suggestions in the category of making wireless devices
> "1st class citizens".  I mostly agree with his suggestions, and they
> are "on my list".  Do we see these as merge requirements?  

The only merge requirement should be that merging d80211 doesn't break
existing in-tree wireless drivers.  We have that today -- you can have
both stacks in the tree and running in parallel.  With that, we have the
ability to migrate over time.

The other 'merge requirements' are functionally irrelevant.  We know the
d80211 stack is where wireless on Linux is going -- the sooner steps are
taken to get that stack out to the masses the faster it can be adopted
and improved.

The agreement to switch to d80211 was reached back in April -- its been
six months and there still doesn't appear to be traction at putting in
action the decisions reached at that time.

If people have issues with with specific components of d80211 prior to
its merging, stand up and state what they are and how not fixing them
would negatively impact people that aren't using the d80211 subsystem.

Don't take the above as me saying there aren't items that need to be
fixed/improved in d80211 -- there is work to be done.  But that
shouldn't stop it from being merged w/ the EXPERIMENTAL flag set.

> Is this agreeable?  Or do we think this needs to happen before a
> merge to -mm?

We reached the point where we should be in -mm a long time ago as soon
as both stacks could exist concurrently.  d80211 should have been in
Linus' tree a long time ago.

James
