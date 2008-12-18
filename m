From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Fri, 19 Dec 2008 00:33:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
References: <1229638581.3726.546.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46007 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239AbYLRWds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 17:33:48 -0500
In-Reply-To: <1229638581.3726.546.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2008, Matt Mackall wrote:

> These debug messages are uninformative and extremely alarming. Rather
> than reporting a peer as a treacherous attacker, report it more
> correctly as simply broken. 

Last time (well, ignoring some report on ancient vendor kernel) I've seen 
this to trigger it wasn't the fault of the peer but ours (we sent past the 
advertized window and window ended up being shrunk to zero). I agree that 
the message as-is is not very good but your change is not very good 
either.

> -			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Treason uncloaked! Peer " NIPQUAD_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",
> +			LIMIT_NETDEBUG(KERN_DEBUG "TCP: Broken peer " NIPQUAD_FMT ":%u/%u shrinks window %u:%u. Repaired.\n",

This won't apply to net-next on which you should base anything new (and 
net related).

-- 
 i.
