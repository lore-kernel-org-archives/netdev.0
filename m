From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 14 Sep 2010 21:56:16 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1009142134440.25664@red.crap.retrofitta.se>
References: <1282024802.2487.687.camel@edumazet-laptop> <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se> <1282055659.2448.58.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se> <20100817171115.GA4134@mcarlson.broadcom.com> <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se> <20100817183112.GA4351@mcarlson.broadcom.com> <alpine.DEB.1.10.1008172035520.21857@red.crap.retrofitta.se>
 <20100818012318.GA4630@mcarlson.broadcom.com> <alpine.DEB.1.10.1008180900350.21857@red.crap.retrofitta.se> <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se> <4C7E65DA.5020106@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C7E65DA.5020106@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sorry for the late reply. I've been swamped.

On Wed, 1 Sep 2010, Brian Haley wrote:
> So are you running with this set to "Shared Network Port" mode?  I'm
> guessing you are.

Yes, there's no dedicated ILO port.

> There was another report on netdev back in 11/2008 on this exact hardware,
> with the same problem.

I can't seem to find it. Do you happen to have the subject line or 
something?

> I dug-up my notes on the problem, and from what I can tell, the receive
> multicast filters on the NIC were getting removed, causing both incoming
> IPv6 and IPv4 multicast packets to get dropped.

Sounds about right. From what I understand the relevant registers were 
still the same for me when it wasn't working though (if that indeed is 
how the filter is implemented).

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
