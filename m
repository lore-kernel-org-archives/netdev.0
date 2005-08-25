From: Danial Thom <danial_thom@yahoo.com>
Subject: Re: 2.6.12 Performance problems
Date: Wed, 24 Aug 2005 23:08:43 -0700 (PDT)
Message-ID: <20050825060843.15874.qmail@web33311.mail.mud.yahoo.com>
References: <430D4E6D.1090200@candelatech.com>
Reply-To: danial_thom@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964856AbVHYGIt@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <430D4E6D.1090200@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- Ben Greear <greearb@candelatech.com> wrote:

> Danial Thom wrote:
> 
> > I think the concensus is that 2.6 has made
> trade
> > offs that lower raw throughput, which is what
> a
> > networking device needs. So as a router or
> > network appliance, 2.6 seems less suitable. A
> raw
> > bridging test on a 2.0Ghz operton system:
> > 
> > FreeBSD 4.9: Drops no packets at 900K pps
> > Linux 2.4.24: Starts dropping packets at 350K
> pps
> > Linux 2.6.12: Starts dropping packets at 100K
> pps
> 
> I ran some quick tests using kernel 2.6.11, 1ms
> tick (HZ=1000), SMP kernel.
> Hardware is P-IV 3.0Ghz + HT on a new
> SuperMicro motherboard with 64/133Mhz
> PCI-X bus.  NIC is dual Intel pro/1000.  Kernel
> is close to stock 2.6.11.
> 
> I used brctl to create a bridge with the two
> GigE adapters in it and
> used pktgen to stream traffic through it
> (250kpps in one direction, 1kpps in
> the other.)
> 
> I see a reasonable amount of drops at 250kpps
> (60 byte packets):
> about 60,000,000 packets received, 20,700
> dropped.
> 
> Interestingly, the system is about 60% idle
> according to top,
> and still dropping pkts, so it would seem that
> the system could
> be better utilized!
> 
> Ben
>

What GigE adapters did you use? Clearly every
driver is going to be different. My experience is
that a 3.4Ghz P4 is about the performance of a
2.0Ghz Opteron. I have to try your tuning script
tomorrow.

If your test is still set up, try compiling
something large while doing the test. The drops
go through the roof in my tests.

Danial


		
____________________________________________________
Start your day with Yahoo! - make it your home page 
http://www.yahoo.com/r/hs 
 
