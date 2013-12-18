From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv4: new ip_no_pmtu_disc mode to always
 discard incoming frag needed msgs
Date: Wed, 18 Dec 2013 16:59:08 -0500 (EST)
Message-ID: <20131218.165908.492719518696161268.davem@davemloft.net>
References: <20131214041345.GO23247@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab3LRV7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:59:09 -0500
In-Reply-To: <20131214041345.GO23247@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 14 Dec 2013 05:13:45 +0100

> This new mode discards all incoming fragmentation-needed notifications
> as I guess was originally intended with this knob. To not break backward
> compatibility too much, I only added a special case for mode 2 in the
> receiving path.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
