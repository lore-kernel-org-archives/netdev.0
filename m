From: Donald Becker <becker@scyld.com>
Subject: Re: pci-skeleton duplex check
Date: Thu, 12 Dec 2002 09:11:34 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0212120857570.10674-100000@beohost.scyld.com>
References: <20021212132033.GA3224@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20021212132033.GA3224@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Dec 2002, Roger Luethi wrote:
> On Wed, 11 Dec 2002 21:42:44 -0500, Donald Becker wrote:
> > Note that the second check ignores 100baseT4, despite it have priority
> > over 10baseT-*.  That was intentional to work around, "a specific issue"
> > with a transceiver.
> 
> That "specific issue" might be worth documenting. Information on such
> quirks is hardest to come by.

There are some quirks I'll refer to as bugs, and some as "issues".

When I get a documented, reliable work-around for a problem that doesn't
impact operation or performance, I consider that chip to be non-buggy.
I try very hard to avoid NDAs, but I'm willing to sign one when it's
clear on both sides what the limits of the NDA are.
Now, if I have to track down the problems myself I can't be certain if
I've found the full extent or correct fix for what is clearly a _bug_. 

[[ I don't know why I bother. The people that now control what goes into
the kernel would rather put in random patches from other people than
accept a correct fix from me. ]]

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
