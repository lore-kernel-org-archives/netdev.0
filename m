From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 7 Jan 2010 21:22:35 +0100
Message-ID: <20100107202235.GA3593@del.dom.local>
References: <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com>
 <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local>
 <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com>
 <20100107185040.GB3208@del.dom.local>
 <20100107193607.GC3208@del.dom.local>
 <4B463C2A.2090209@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752605Ab0AGUWo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B463C2A.2090209@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2010 at 02:55:22PM -0500, Michael Breuer wrote:
> On 1/7/2010 2:36 PM, Jarek Poplawski wrote:
> >On Thu, Jan 07, 2010 at 07:50:40PM +0100, Jarek Poplawski wrote:
> >>>Going to rerun with these patches and with and without MMAP. Will
> >>>also retry both with jumbo frames if possible.
> >>If MMAP then some "alternative" too. But first no MMAP.
> >Another things IMHO worth to try: a sky2 module parameter
> >"disable_msi=1", and CONFIG_DMAR off.
> >
> >Jarek P.
> Ok - that'd be with or without MMAP enabled? (note that so-far,
> without MMAP I'm not seeing any errors - throughput is running about
> half what I was seeing with MMAP enabled (before crashing that is).
> CPU is also way busier (also to be expected). One other observation
> - I had been seeing lots of DNS errors - IPV6 related format errors
> I really didn't think much of it as they were mostly .ru and seemed
> spam-related, but now I don't see any. Haven't updated bind; doubt
> the world has changed - so perhaps this is related to the network
> issue.

MMAP enabled (with some "alternative" patch - to avoid known bugs)
should give as earlier the answer if these changes matter. But first
let's try longer (if possible) if this "no MMAP" could really heal
your hardware.

Jarek P.
