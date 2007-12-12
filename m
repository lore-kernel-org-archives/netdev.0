From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH] iproute2: support dotted-quad netmask notation.
Date: Wed, 12 Dec 2007 12:55:13 +0100
Message-ID: <20071212115513.GA3394@scream.fatal.se>
References: <20071204135818.GA24419@scream.fatal.se> <20071206115350.18e9204f@freepuppy.rosehill> <1197070894.5385.14.camel@localhost.localdomain> <1197220222.4392.9.camel@localhost.localdomain> <20071211171406.57389dba@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38948 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbXLLMLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 07:11:40 -0500
Content-Disposition: inline
In-Reply-To: <20071211171406.57389dba@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 05:14:06PM -0800, Stephen Hemminger wrote:
> On Sun, 09 Dec 2007 18:10:22 +0100
> Andreas Henriksson <andreas@fatal.se> wrote:
> > I think both previous patches where broken on big-endian platforms.
> > Here's an updated patch again. I'm very sorry for the inconvenience!
[...]
> > +		*val=0;
> > +		for (mask = ntohl(addr.data[0]); mask; mask <<= 1)
> > +			(*val)++;
[...]
> 
> applied
> 

Just to make sure.... It looks on git.kernel.org like you applied the wrong
patch. (Maybe you just haven't pushed out the latest changes there yet.)
Please double-check that you actually applied the latest version (which is
the one in the mail you replied "applied" to, important part quoted above). 


Additionally, there's still a couple of trivial patches pending in
the "patches" branch of 
git://git.debian.org/git/collab-maint/pkg-iproute.git

Please see the original thread[1], where Patrick McHarding had some concerns
about one of the patches. It's exactly the same changes you made in commit
660818498d0f5a3f52c05355a3e82c23f670fcc1 [2] though, so I don't really see the
problem. I have an additional patch[3] available, that makes MAX_ROUNDS
configurable which Patrick requested.

Please comment on the way forward there....


[1]: http://www.spinics.net/lists/netdev/msg44800.html
[2]: Where the comment seems to be wrong about "Limit ip route flush...",
     since it's actually "ip neigh flush" that's being modified.
[3]: I have a slightly updated patch, but it's basically the same as
     http://www.spinics.net/lists/netdev/msg45080.html
	 Will send updated version if the patches it's based on goes in.

-- 
Regards,
Andreas Henriksson
