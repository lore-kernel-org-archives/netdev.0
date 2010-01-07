From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 7 Jan 2010 19:50:40 +0100
Message-ID: <20100107185040.GB3208@del.dom.local>
References: <4B4571D5.30002@majjas.com>
 <4B457711.1040008@majjas.com>
 <4B458B36.6050509@majjas.com>
 <20100107074756.GB6258@ff.dom.local>
 <4B459368.2000503@majjas.com>
 <4B45F841.8030407@majjas.com>
 <20100107180114.GB3088@del.dom.local>
 <4B4625BD.3070202@majjas.com>
 <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753528Ab0AGSuu@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B462B3C.90506@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2010 at 01:43:08PM -0500, Michael Breuer wrote:
> On 1/7/2010 1:35 PM, Jarek Poplawski wrote:
> >On Thu, Jan 07, 2010 at 01:19:41PM -0500, Michael Breuer wrote:
> >>On 1/7/2010 1:01 PM, Jarek Poplawski wrote:
> >>>On Thu, Jan 07, 2010 at 10:05:37AM -0500, Michael Breuer wrote:
> >>>>Bad news - crashed about an hour after I wrote this email - under
> >>>>load - same crash as before. Network watchdog... lots of attempts to
> >>>>reset the adapter... then hw watchdog rebooted the system.
> >>>It's a pity. Anyway, I'd be still interested in CONFIG_PACKET_MMAP off
> >>>if you find time.
> >>>
> >>>Jarek P.
> >>Ok - any particular patch set to try with? I'm going to start with a
> >>clean tree using the latest 2.6.32 from git (tried 2.6.33-rc3, but
> >>can't get a usable console... will look at that later.)
> >My "Berck E. Nash" and Stephen's "pskb_may_pull" sky2 patches. (BTW,
> >could you remind if it worked any better with 2.6.31 or earlier?)
> >
> >Jarek P.
> I'm not sure my crash-and-burn runs yesterday included the
> pskb_may_pull patch :(
> 
> Going to rerun with these patches and with and without MMAP. Will
> also retry both with jumbo frames if possible.

If MMAP then some "alternative" too. But first no MMAP.

Jarek P.
