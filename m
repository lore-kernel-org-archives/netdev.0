From: Nix <nix@esperi.org.uk>
Subject: Re: 3.19+: (and quite probably earlier) VIA Rhine hanging under high network load, yet again: redux
Date: Sat, 04 Apr 2015 22:26:39 +0100
Message-ID: <87k2xr60vk.fsf@spindle.srvr.nix>
References: <874mov7otu.fsf@spindle.srvr.nix>
	<20150404210518.GA7698@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:46407 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656AbbDDV0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 17:26:46 -0400
In-Reply-To: <20150404210518.GA7698@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Sat, 4 Apr 2015 23:05:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 Apr 2015, Francois Romieu told this:

> Nix <nix@esperi.org.uk> :
> [...]
>
> This driver leaves holes in its receive ring under memory pressure.
> It may not help.

... OK so that is something I really should have spotted. I wasn't
looking at the driver's response to memory-shortage conditions because
this machine, though swapless, has wads of memory free under normal
conditions:

nix@fold 2 /home/nix% cat /proc/meminfo
MemTotal:         515720 kB
MemFree:          376552 kB
MemAvailable:     417120 kB

But of course this is networking, so we need skb_allocable memory, which
might be in much shorter supply than merely reclaimable/available memory
(though, again, 376552kB should be enough, you'd think).

> You can try the gross patch below against v3.19. It compiles. I have to go.

All I can say is "good grief, a response at Eastertime?! Valour beyond
the call of duty!"

I'll give it a try tomorrow :) but whether it works or not, I owe you a
drink next time you're in the UK south-east for spending any time at all
on this at Easter!

-- 
NULL && (void)
