From: Tim Gardner <timg@tpi.com>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 14:58:37 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095800316.3934.88.camel@tim.rtg.net>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
	 <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi>
	 <20040922.010428.104988024.yoshfuji@linux-ipv6.org>
	 <1095784761.3934.52.camel@tim.rtg.net>
	 <20040921173134.GC12132@wotan.suse.de>
	 <1095789507.3934.69.camel@tim.rtg.net>
	 <20040921181525.GB18938@wotan.suse.de>
	 <20040921203404.GA3236@sunbeam.de.gnumonks.org>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>,
        pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040921203404.GA3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> My personal (simplistic) favourite is still a simple threshold (absolute
> value / percentage) for incomplete neighbour entries. This way we make
> sure that we cannot starve 'real' (fully resolved) entries at the cost
> of incomplete ones.
> 
> > -Andi

It's not like NUD doesn't already have an overflow policy.
neigh_forced_gc() performs a cleanup on NUD_INCOMPLETE entries when
gc_thresh3 is exceeded.

rtg
-- 
timg@tpi.com http://www.tpi.com
406-443-5357(MT) 503-601-0234(OR)
