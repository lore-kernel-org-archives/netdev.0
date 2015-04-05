From: Nix <nix@esperi.org.uk>
Subject: Re: 3.19+: (and quite probably earlier) VIA Rhine hanging under high network load, yet again: redux
Date: Sun, 05 Apr 2015 21:59:25 +0100
Message-ID: <877ftqxpea.fsf@spindle.srvr.nix>
References: <874mov7otu.fsf@spindle.srvr.nix>
	<20150404210518.GA7698@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:42472 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbbDEU7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 16:59:36 -0400
In-Reply-To: <20150404210518.GA7698@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Sat, 4 Apr 2015 23:05:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 Apr 2015, Francois Romieu said:

> Nix <nix@esperi.org.uk> :
> [...]
>
> This driver leaves holes in its receive ring under memory pressure.
> It may not help.
>
> You can try the gross patch below against v3.19. It compiles. I have to go.

Gross or not, it seems to work: I've loaded it enough to crash it half a
dozen times, and not a crash. However, the rx_dropped stats on the link
aren't going up, so maybe I've just been lucky.

I'll put it under more load tomorrow :)

-- 
NULL && (void)
