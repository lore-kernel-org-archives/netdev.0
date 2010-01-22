From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Sat, 23 Jan 2010 00:06:05 +0100
Message-ID: <20100122230605.GB3105@del.dom.local>
References: <20100120094103.GA6225@ff.dom.local>
 <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local>
 <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local>
 <4B5A2362.6000306@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755411Ab0AVXGO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5A2362.6000306@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 22, 2010 at 05:14:58PM -0500, Michael Breuer wrote:
> On 1/22/2010 4:53 PM, Jarek Poplawski wrote:
> >On Fri, Jan 22, 2010 at 01:01:15PM -0500, Michael Breuer wrote:
> >>Kernel 2.6.32.4 (git) with the following patches applied:
> >>
> >>af_packet.c (tpacket_snd version 3)
> >>sky2.c pskb_may_pull
> >>sky2 fix WARNING at lib/dma-debug.c check_sync
> >I guess, you meant the "sky2.c receive_copy" patch which you tested
> >earlier, or at least you managed to crash DMAR with that patch
> >before crashing it with Stephen's "lib/dma-debug.c check_sync" patch,
> >right?
> >
> Yes - sorry, correct - all three patches were in the last run.
> Previously, I've encountered the crash without these patches.

OK, thanks for testing - it's really very helpful, and supports
David's opinion that dmar is a different problem.
...
> Not sure I can do that. Note that based on the log messages, there
> were no errors/dropped packets involving dhcp. Moving the dhcp
> server off of the affected machine is not trivial. The dhcp
> correlation is based on logged messages preceding each crash. I
> cannot confirm that they're related, however it's really suspicious.
> If it helps, HP replaced my unmanaged switch with a managed one so I
> can see whether there were any switch events logged the next time I
> have a crash.
> 
> At this point, it seems the following is required to trigger the crash:
> 1) Uptime of 24-36 hours
> 2) High RX load on server (cifs traffic is what I've triggered it with).
> 3) Normal DHCP traffic.

Do you mean you got these crashes with the new switch too, and this
switch doesn't drop DHCP at all? (Otherwise, let's try this switch
first.)

Jarek P.
