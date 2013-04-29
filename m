From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: mac802154: comparision issue of type cast,
 finding by EXTRA_CFLAGS=-W
Date: Mon, 29 Apr 2013 12:29:34 -0400 (EDT)
Message-ID: <20130429.122934.2073602835665028801.davem@davemloft.net>
References: <5178FA0D.8060009@asianux.com>
	<5178FE6A.3050108@redhat.com>
	<51790A53.8040107@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, c.aeschlimann@acn-group.ch,
	sergei.shtylyov@cogentembedded.com,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758016Ab3D2Q3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 12:29:37 -0400
In-Reply-To: <51790A53.8040107@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Thu, 25 Apr 2013 18:49:55 +0800

> 
> Change MAC802154_CHAN_NONE from ~(u8)0 to 0xff, or the comparison in
> mac802154_wpan_xmit() for ``chan == MAC802154_CHAN_NONE'' will not
> succeed.
> 
> This bug can be boiled down to ``u8 foo = 0xff; if (foo == ~(u8)0)
> [...] else [...]'' where the condition will always take the else
> branch. 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Applied, thanks.
