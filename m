From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Fri, 22 Jan 2010 22:53:04 +0100
Message-ID: <20100122215304.GA3105@del.dom.local>
References: <20100120094103.GA6225@ff.dom.local>
 <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local>
 <4B59E7EB.3050605@majjas.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754814Ab0AVVxS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B59E7EB.3050605@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 22, 2010 at 01:01:15PM -0500, Michael Breuer wrote:
> Kernel 2.6.32.4 (git) with the following patches applied:
> 
> af_packet.c (tpacket_snd version 3)
> sky2.c pskb_may_pull
> sky2 fix WARNING at lib/dma-debug.c check_sync

I guess, you meant the "sky2.c receive_copy" patch which you tested
earlier, or at least you managed to crash DMAR with that patch
before crashing it with Stephen's "lib/dma-debug.c check_sync" patch,
right?

> Running with CONFIG_DMAR=n, system is stable.
> Running with the exact same source but CONFIG_DMAR=y I get the
> WARNING (see below) after about 36 hours of uptime (has varied from
> about 24 to about 48):
> Smolt profile: http://smolt.fedoraproject.org/show?uuid=pub_bb05c701-1e47-4b3c-9fab-54f520f39d79+
> I'm also attaching dmesg.old (dmesg from the crash).
> 
> Subsequent to this the system watchdog reboots the system (it's hung).
> 
> Of interest: each and every time this has happened the system was
> under heavy RX load (win7 backup to a cifs share hosted on this
> server). Also, there is always a dhcp exchange of some sort
> preceding the event.
> 
> It is possible that the event is re creatable without DMAR enabled,
> but I have been unsuccessful in doing so.

It would be nice to check now if it's re-creatable without the dhcp
exchange yet, or at least dhcp through the switch and the router,
because I suspect there might be something more than a simple drop
on the switch that affects sky2 stability.

Jarek P.
