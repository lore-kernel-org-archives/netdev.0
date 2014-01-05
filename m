From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ipv4: add forwarding_uses_pmtu knob to
 protect forward path to use pmtu info
Date: Sun, 05 Jan 2014 14:45:46 -0500 (EST)
Message-ID: <20140105.144546.1466474312391379351.davem@davemloft.net>
References: <20131220130822.GD32129@order.stressinduktion.org>
	<20131230.222044.884570280065942449.davem@davemloft.net>
	<20140105104109.GE25828@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	steffen.klassert@secunet.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbaAETpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 14:45:50 -0500
In-Reply-To: <20140105104109.GE25828@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 5 Jan 2014 11:41:09 +0100

> What do you mean here by non-tunneled IPSEC? Transport mode is not an issue
> with this patch as we don't push packets for transport mode through
> forwarding.

Right you are.
