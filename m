From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reorder some fields of net_device
Date: Sat, 30 Mar 2013 17:31:53 -0400 (EDT)
Message-ID: <20130330.173153.1283819859704936260.davem@davemloft.net>
References: <1364661063.5113.116.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab3C3Vby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 17:31:54 -0400
In-Reply-To: <1364661063.5113.116.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Mar 2013 09:31:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As time passed, some fields were added in net_device, and not
> at sensible offsets.
> 
> Lets reorder some fields to reduce number of cache lines in RX path.
> Fields not used in data path should be moved out of this critical cache
> line.
> 
> In particular, move broadcast[] to the end of the rx section,
> as it is less used, and ethernet uses only the beginning of the 32bytes
> field.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
