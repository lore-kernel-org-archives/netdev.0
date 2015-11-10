From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix a race in dst_release()
Date: Mon, 09 Nov 2015 21:56:39 -0500 (EST)
Message-ID: <20151109.215639.72685911796993165.davem@davemloft.net>
References: <1447120283.17135.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gthelen@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbbKJC4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 21:56:40 -0500
In-Reply-To: <1447120283.17135.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Nov 2015 17:51:23 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Only cpu seeing dst refcount going to 0 can safely
> dereference dst->flags. 
> 
> Otherwise an other cpu might already have freed the dst.
> 
> Fixes: 27b75c95f10d ("net: avoid RCU for NOCACHE dst")
> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Ouch...

Applied and queued up for -stable, thanks.
