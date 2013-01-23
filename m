From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IP_GRE: Linearize skb before csum.
Date: Wed, 23 Jan 2013 00:19:56 -0500 (EST)
Message-ID: <20130123.001956.1988771856502410155.davem@davemloft.net>
References: <20130122.204629.607263597214211092.davem@davemloft.net>
	<20130122.232235.643904201225800004.davem@davemloft.net>
	<1358917373.12374.707.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab3AWFUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:20:00 -0500
In-Reply-To: <1358917373.12374.707.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Jan 2013 21:02:53 -0800

> GSO was a bad idea from the very beginning, if you want
> such use case. 

It's perfectly fine when the card checksums the packet.  Because it
will checksum the exact data that will hit the wire and thus the
checksum will be correct always.

It's only buggy when we do pure software GSO and have page frags.
