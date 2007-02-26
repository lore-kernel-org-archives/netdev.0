From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [RFC] div64_64 support
Date: Mon, 26 Feb 2007 21:09:26 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
References: <20070223170527.4ca695b2@freekitty>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmailer.gwdg.de ([134.76.10.23]:38890 "EHLO tmailer.gwdg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030637AbXBZUKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 15:10:19 -0500
In-Reply-To: <20070223170527.4ca695b2@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 23 2007 17:05, Stephen Hemminger wrote:
>
>Since there already two users of full 64 bit division in the kernel,
>and other places maybe hiding out as well. Add a full 64/64 bit divide.
>
>Yes this expensive, but there are places where it is necessary.
>It is not clear if doing the scaling buys any advantage on 64 bit platforms,
>so for them a full divide is done.
>
>---
> include/asm-arm/div64.h      |    2 ++
> include/asm-generic/div64.h  |    8 ++++++++
> include/asm-m68k/div64.h     |    2 ++
> include/asm-mips/div64.h     |    8 ++++++++
> include/asm-um/div64.h       |    1 +
> include/asm-xtensa/div64.h   |    1 +
> lib/div64.c                  |   22 ++++++++++++++++++++++
> net/ipv4/tcp_cubic.c         |   22 ----------------------
> net/netfilter/xt_connbytes.c |   16 ----------------
> 9 files changed, 44 insertions(+), 38 deletions(-)

Actually, there is udivdi3 support in the kernel

./arch/arm26/lib/udivdi3.c
./arch/sh/lib/udivdi3.c
./arch/sparc/lib/udivdi3.S

should not this be consolidated too?




Jan
-- 
ft: http://freshmeat.net/p/chaostables/
