From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 0/3] sh_eth: Remove redundant alignment adjustment
Date: Thu, 13 Nov 2014 10:04:20 +0100
Message-ID: <CAMuHMdVm9_gUToUjgFh4SwrfxzBvzHcNDb+CNkKyaz6mcT2AJg@mail.gmail.com>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:43122 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932249AbaKMJEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 04:04:22 -0500
In-Reply-To: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kaneko-san,

On Thu, Nov 13, 2014 at 8:04 AM, Yoshihiro Kaneko <ykaneko0929@gmail.com> wrote:
> This series is based on net tree.
>
> Mitsuhiro Kimura (3):
>   sh_eth: Remove redundant alignment adjustment
>   sh_eth: Fix skb alloc size and alignment adjust rule.
>   sh_eth: Fix dma mapping issue

Thanks!

I've applied this series, and your series "[PATCH 0/2] Fix sleeping function
called from invalid context", and the warnings from dma-debug.c I was
seeing on r8a7791/koelsch are gone.

Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
