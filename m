From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 23:18:45 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306092251180.28167@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030610015311.GB23009@netnation.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, CIT/Paul <xerox@foonet.net>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030610015311.GB23009@netnation.com>
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003, Simon Kirby wrote:

> "vmstat 1") except in attack cases.  The difference is probably just the
> fact that this is running on slightly faster hardware (single Athlon
> 1800MP, Tyan Tiger MPX board).

What happened to Linux users being able to brag about how much they could
do with CPUs that were useless for running Windows?  On a 1Ghz CPU you've
got almost 7,000 cycles to route a packet in order to handle 148kpps.  I
can't see why the slow path should be more than 2,000 cycles.

I know some people's attitude is don't talk if you're not going to write
the code.  If I had the time I would; from my earliest days of programming
I've been optimizing performance to the maximum.  I can still remember
using page 0 on my c64 to store an 8-bit register in 3 cycles instead of
four...

So to put a stake in the ground, I'd like to see a 1Ghz celeron with e1000
cards handle 148kpps of DOS traffic at <50% CPU utilization (with full
routing tables & no firewalling).  If that's not a reasonable expectation,
someone please let me know.  Even if my time was only worth $500/day, in
the past year and a half I spent enough time working on Linux routers to
buy a Cisco NPE-G1. :-(

-Ralph
