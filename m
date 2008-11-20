From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: use seq_release_private for ip6mr.c /proc entries
Date: Thu, 20 Nov 2008 04:16:24 -0800 (PST)
Message-ID: <20081120.041624.120712715.davem@davemloft.net>
References: <20081119204128.826163131@theryb.frec.bull.fr>
	<20081119204141.938837793@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60502
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754122AbYKTMQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:16:24 -0500
In-Reply-To: <20081119204141.938837793@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Wed, 19 Nov 2008 21:41:38 +0100

> In ip6mr.c, /proc entries /proc/net/ip6_mr_cache and /proc/net/ip6_mr_vif
> are opened with seq_open_private(), thus seq_release_private() should be 
> used to release them.
> Should fix a small memory leak.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks a lot Benjamin.
