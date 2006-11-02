From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Wed, 01 Nov 2006 19:30:01 -0500
Message-ID: <45493C09.9050707@garzik.org>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Simon Barber <simon@devicescape.com>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58523 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1752614AbWKBAaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 19:30:18 -0500
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <4548E7F7.7030100@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> If people have issues with with specific components of d80211 prior to
> its merging, stand up and state what they are and how not fixing them
> would negatively impact people that aren't using the d80211 subsystem.
> 
> Don't take the above as me saying there aren't items that need to be
> fixed/improved in d80211 -- there is work to be done.  But that
> shouldn't stop it from being merged w/ the EXPERIMENTAL flag set.

> We reached the point where we should be in -mm a long time ago as soon
> as both stacks could exist concurrently.  d80211 should have been in
> Linus' tree a long time ago.

d80211 merge stoppers:
- SMP issues (lack of locking, and overlocking via use of Big Network Lock)
- userspace ABI

It definitely shouldn't go upstream without that stuff.

	Jeff


