From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] syncookies: do not store rcv_wscale in tcp
 timestamp
Date: Sat, 26 Jun 2010 22:00:46 -0700 (PDT)
Message-ID: <20100626.220046.209981863.davem@davemloft.net>
References: <1277156925-7295-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34566
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750948Ab0F0FAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 01:00:37 -0400
In-Reply-To: <1277156925-7295-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 21 Jun 2010 23:48:44 +0200

> As pointed out by Fernando Gont there is no need to encode rcv_wscale
> into the cookie.
> 
> We did not use the restored rcv_wscale anyway; it is recomputed
> via tcp_select_initial_window().
> 
> Thus we can save 4 bits in the ts option space by removing rcv_wscale.
> In case window scaling was not supported, we set the (invalid) wscale
> value 0xf.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
