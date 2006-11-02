From: James Ketrenos <jketreno@linux.intel.com>
Subject: d80211 merge (was Re: [patch] d80211: use pfifo_qdisc_ops rather
 than d80211-specific qdisc)
Date: Wed, 01 Nov 2006 17:48:01 -0800
Message-ID: <45494E51.7070707@linux.intel.com>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com> <45493C09.9050707@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:35239 "EHLO
	orsmga101.jf.intel.com") by vger.kernel.org with ESMTP
	id S1752455AbWKBBqu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 20:46:50 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45493C09.9050707@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> James Ketrenos wrote:
>> If people have issues with with specific components of d80211 prior to
>> its merging, stand up and state what they are and how not fixing them
>> would negatively impact people that aren't using the d80211 subsystem.
>>
>> Don't take the above as me saying there aren't items that need to be
>> fixed/improved in d80211 -- there is work to be done.  But that
>> shouldn't stop it from being merged w/ the EXPERIMENTAL flag set.
> 
>> We reached the point where we should be in -mm a long time ago as soon
>> as both stacks could exist concurrently.  d80211 should have been in
>> Linus' tree a long time ago.
> 
> d80211 merge stoppers:
> - SMP issues (lack of locking, and overlocking via use of Big Network Lock)

So we can set BROKEN_ON_SMP on it and we're good.  The entire
description of EXPERIMENTAL in init/Kconfig matches perfectly what we
want -- bug reports, wider exposure, and a clear articulation that the
feature is unstable.

> - userspace ABI

What's the requirement on the userspace ABI?  That the existing wireless
extension interface needs to work, or ?

We can use the wireless extension currently to match (most of) the
existing WE functionality -- at least to get the majority of wireless
users up and running (for those that have cards that have d80211 drivers
anyway).

> It definitely shouldn't go upstream without that stuff.

How will merging with the existing locking problems or ABI issue
negatively impact people that aren't using the d80211 subsystem anyway?

If having the code there doesn't hurt anyone, why not get it out for
wider adoption, exposure, and contribution?

Why is there such a hesitation to merge this stack and help to
accelerate the set of functionality available with wireless on Linux?

James
