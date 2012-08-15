From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove wrong initialization for snd_wl1
Date: Wed, 15 Aug 2012 15:23:34 -0700 (PDT)
Message-ID: <20120815.152334.334391000010431604.davem@davemloft.net>
References: <1344951021-22667-1-git-send-email-rghitulete@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, dbaluta@ixiacom.com
To: rghitulete@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750923Ab2HOWXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 18:23:36 -0400
In-Reply-To: <1344951021-22667-1-git-send-email-rghitulete@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Razvan Ghitulete <rghitulete@ixiacom.com>
Date: Tue, 14 Aug 2012 16:30:20 +0300

> The field tp->snd_wl1 is twice initialized, the second time
> seems to be wrong as it may overwrite any update in tcp_ack.
> 
> Signed-off-by: Razvan Ghitulete <rghitulete@ixiacom.com>

I'll apply this, but it is mere redundancy.

The only thing tcp_ack() can set tp->snd_wl1 to is TCP_SKB_CB(skb)->seq
which is exactly what it is being set to here as well.
