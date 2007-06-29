From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 29 Jun 2007 17:07:59 +0200
Message-ID: <20070629150759.GC2771@ff.dom.local>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933054AbXF2PAF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 29, 2007 at 10:50:20AM +0200, Jean-Baptiste Vignaud wrote:
> Update...
> I did 2 tests :
> 
> 1)  booted with option acpi=off
> It booted correctly, i managed to get some load on one of the card
> and after a while (10 minutes i guess) the Timeout occurs. Side effect,
> at the same moment the sata contolers lost control of the disks somehow
> and the raid 5 array on the system crashed hard. I have no traces as i
> was unable to rebuild it (and i tried a lot of extreme  voodoo methods).

I think the main option: acpi=on is usually needed.

If you, guys, are not exhausted yet, I think you could try to
turn off (or change for somethig else) most of the options from
"Processors type and features", and maybe something below PCI
support. But there are many new options which couldn't be turned
off so easy, so there is no much hope...

> 
> 2) changed the 3com cards
> i replaced by two cards,
> 01:06.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 42)
> 01:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
> 
> reinstalled and stressed the network (small download from a laptop) and :
> 
> Jun 29 09:34:10 loki kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Jun 29 09:34:51 loki last message repeated 14 times
> Jun 29 09:35:18 loki last message repeated 8 times
> 
> so it seems to be a more generic problem.

I wonder if you tried to change the place - I've read this
advice many times. And maybe it would be better to try with
one card at first?

It seems there are some patches with dev->tx_timeout but it
looks like fixing results only. Let's wait...

Cheers,
Jarek P.

PS: Marcin - your last message wasn't plain text - so probably
dumped by kernel lists. 
