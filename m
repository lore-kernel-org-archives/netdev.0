From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 4/4] drivers/atm/idt77252.c: Remove unnecessary error
 check
Date: Sat, 2 Oct 2010 16:21:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1010021621000.21879@ask.diku.dk>
References: <1286027958-7333-4-git-send-email-julia@diku.dk> <4CA73D26.7090109@bfs.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: walter harms <wharms@bfs.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CA73D26.7090109@bfs.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2 Oct 2010, walter harms wrote:

> 
> 
> Julia Lawall schrieb:
> > This code does not call deinit_card(card); in an error case, as done in
> > other error-handling code in the same function.  But actually, the called
> > function init_sram can only return 0, so there is no need for the error
> > check at all.
> > 
> 
> 
> did you set init_sram() to void ?

No, that indeed seems like a reasonable change.  Patch shortly.

julia
