From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Sun, 04 Feb 2007 23:36:58 -0800 (PST)
Message-ID: <20070204.233658.130236812.davem@davemloft.net>
References: <20070202144116.26863.3722.sendpatchset@galon.ev-en.org>
	<20070202144121.26863.90947.sendpatchset@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52082
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752765AbXBEHg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 02:36:59 -0500
In-Reply-To: <20070202144121.26863.90947.sendpatchset@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Fri, 02 Feb 2007 16:41:21 +0200

> Move DSACK code outside the SACK fast-path checking code. If the DSACK
> determined that the information was too old we stayed with a partial cache
> copied. Most likely this matters very little since the next packet will not be
> DSACK and we will find it in the cache. but it's still not good form and there
> is little reason to couple the two checks.
> 
> Since the SACK receive cache doesn't need the data to be in host order we also
> remove the ntohl in the checking loop.
> 
> Signed-Off-By: Baruch Even <baruch@ev-en.org>

Thanks for fixing up the endianness annotations, applied.
