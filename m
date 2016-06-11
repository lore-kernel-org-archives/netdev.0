From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] sched: remove NET_XMIT_POLICED
Date: Fri, 10 Jun 2016 23:31:37 -0700 (PDT)
Message-ID: <20160610.233137.888795126611100309.davem@davemloft.net>
References: <1465561289-15401-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a@unstable.cc, sw@simonwunderlich.de,
	mareklindner@neomailbox.ch, sven@narfation.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbcFKGbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 02:31:38 -0400
In-Reply-To: <1465561289-15401-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 10 Jun 2016 14:21:29 +0200

> ... its not returned anywhere.
> 
> BATMAN uses it as an intermediate return value to signal
> forwarding vs. buffering, but it will not return POLICED to
> callers outside of BATMAN.
> 
> sch_atm uses it, but on closer look its not returned either since
> the initialisation is always overwritten with qdisc_enqueue() retval.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
