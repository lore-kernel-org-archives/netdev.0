From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 14:41:13 -0700
Message-ID: <20100517144113.0a3cd438@nehalam>
References: <4BF192F9.8000008@candelatech.com>
	<4BF1A352.5020500@candelatech.com>
	<4BF1A6D1.70507@candelatech.com>
	<20100517203004.GD8301@sequoia.sous-sol.org>
	<4BF1A855.3090905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>, NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60082 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754840Ab0EQVlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 17:41:16 -0400
In-Reply-To: <4BF1A855.3090905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 13:34:29 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 05/17/2010 01:30 PM, Chris Wright wrote:
> > * Ben Greear (greearb@candelatech.com) wrote:
> >> On 05/17/2010 01:13 PM, Ben Greear wrote:
> >>> On 05/17/2010 12:03 PM, Ben Greear wrote:
> >>>> On older releases, you can do this with iproute:
> >>>>
> >>>> # ip ru add from 9.9.9.2/32 table 226 pref 400
> >>>> #
> >>>>
> >>>> But, in latest git, it returns an error:
> >>>> # ip ru add from 9.9.9.2/32 table 226 pref 400
> >>>> Error: an inet prefix is expected rather than "9.9.9.2/32".
> >>>>
> >>>> Is that on purpose?
> >>>
> >>> I was thinking maybe this was a library issue, since I compiled
> >>> on one machine and ran the 'ip' exe on another. So, I tried compiling
> >>> on the test system.
> >>
> >> I'm not thinking too well today, but this patch fixes the compile.
> >> No idea if it's actually correct code.
> >
> > Needs more changes than that patch.
> 
> Ok, I'll try going back a few commits to find something that compiles
> w/out my hacks.
> 
> Also, the rule addition does work..make install put ip in
> a different place than it's installed in fedora, so I wasn't
> actually running the latest code when I first tried to add
> the rule.

Distributions never seem to agree where it should be: /sbin or /usr/sbin
or even /bin

