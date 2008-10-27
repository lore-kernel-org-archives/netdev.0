From: David Miller <davem@davemloft.net>
Subject: Re: suspicious logic in tcp_make_synack()
Date: Sun, 26 Oct 2008 23:11:02 -0700 (PDT)
Message-ID: <20081026.231102.214077979.davem@davemloft.net>
References: <20081026.010158.193698298.davem@davemloft.net>
	<20081026174147.GB27584@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36008
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750945AbYJ0GLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 02:11:24 -0400
In-Reply-To: <20081026174147.GB27584@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 26 Oct 2008 18:41:47 +0100

> syncookies: fix inclusion of tcp options in syn-ack
> 
> David Miller noticed that commit
> 33ad798c924b4a1afad3593f2796d465040aadd5 '(tcp: options clean up')
> did not move the req->cookie_ts check.
> This essentially disabled commit 4dfc2817025965a2fc78a18c50f540736a6b5c24
> '[Syncookies]: Add support for TCP options via timestamps.'.
> 
> This restores the original logic.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks a lot Florian.

I can't count on my two hands how many bugs were caused by that one
single commit :-(
