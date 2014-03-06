From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: remove now unused flag DST_NOPEER
Date: Thu, 06 Mar 2014 13:17:59 -0500 (EST)
Message-ID: <20140306.131759.919308594900286132.davem@davemloft.net>
References: <20140306081107.GD26307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbaCFSSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 13:18:01 -0500
In-Reply-To: <20140306081107.GD26307@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 6 Mar 2014 09:11:07 +0100

> Commit e688a604807647 ("net: introduce DST_NOPEER dst flag") introduced
> DST_NOPEER because because of crashes in ipv6_select_ident called from
> udp6_ufo_fragment.
> 
> Since commit 916e4cf46d0204 ("ipv6: reuse ip6_frag_id from
> ip6_ufo_append_data") we don't call ipv6_select_ident any more from
> ip6_ufo_append_data, thus this flag lost its purpose and can be removed.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
