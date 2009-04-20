From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] syncookies: remove last_synq_overflow from struct
 tcp_sock
Date: Mon, 20 Apr 2009 02:26:13 -0700 (PDT)
Message-ID: <20090420.022613.84087091.davem@davemloft.net>
References: <1240170228-26241-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33610
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754412AbZDTJ0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:26:21 -0400
In-Reply-To: <1240170228-26241-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 19 Apr 2009 21:43:48 +0200

> last_synq_overflow eats 4 or 8 bytes in struct tcp_sock, even
> though it is only used when a listening sockets syn queue
> is full.
> 
> We can (ab)use rx_opt.ts_recent_stamp to store the same information;
> it is not used otherwise as long as a socket is in listen state.
> 
> Move linger2 around to avoid splitting struct mtu_probe
> across cacheline boundary on 32 bit arches.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

This looks good, applied, thanks.
