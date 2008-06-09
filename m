From: David Miller <davem@davemloft.net>
Subject: Re: [patch, v2.6.26-rc5] net/irda build fix: mcs7780
Date: Mon, 09 Jun 2008 15:47:52 -0700 (PDT)
Message-ID: <20080609.154752.148433093.davem@davemloft.net>
References: <20080604.170123.234927220.davem@davemloft.net>
	<20080609082257.GA15282@elte.hu>
	<47304c8330b37ab2677d72f8c8adbe12@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754193AbYFIWrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:47:52 -0400
In-Reply-To: <47304c8330b37ab2677d72f8c8adbe12@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <samuel@sortiz.org>
Date: Mon, 09 Jun 2008 11:26:37 +0200

> 
> On Mon, 9 Jun 2008 10:22:57 +0200, Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > -tip testing found the following build error:
> > 
> >   drivers/built-in.o: In function `mcs_receive_irq':
> >   mcs7780.c:(.text+0x4e429): undefined reference to `crc32_le'
> >   drivers/built-in.o: In function `mcs_hard_xmit':
> >   mcs7780.c:(.text+0x4e9af): undefined reference to `crc32_le'
> > 
> > with:
> > 
> >   http://redhat.com/~mingo/misc/config-Sun_Jun__8_22_56_14_CEST_2008.bad
> > 
> > the reason is a missing enablement of the CRC32 library in the Kconfig.
> > 
> > Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Many thanks Ingo.
> 
> Dave, I can take it with my next IrDA patch set. But since it's a build
> failure, you may want to take it immediatly, it's up to you.
> In the latter case:
> 
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

I'll apply this now, thanks everyone.
