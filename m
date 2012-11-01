From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] packet: tx_ring: allow the user to choose
 tx data offset
Date: Thu, 01 Nov 2012 10:54:21 -0400 (EDT)
Message-ID: <20121101.105421.1443685043169389365.davem@davemloft.net>
References: <1350889014-2975-1-git-send-email-paul.chavent@onera.fr>
	<20121031.131434.910561089094397853.davem@davemloft.net>
	<5091967F.9050907@fnac.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Paul.Chavent@onera.fr, netdev@vger.kernel.org
To: paul.chavent@fnac.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59964 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760190Ab2KAOyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 10:54:24 -0400
In-Reply-To: <5091967F.9050907@fnac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Chavent <paul.chavent@fnac.net>
Date: Wed, 31 Oct 2012 22:22:07 +0100

> It seems that the user can already fire an error msg by simply pass a
> too long tp_len.
> 
> Though, should i remove it from the tpacket_fill_skb function and
> silently return -EINVAL ?

Returning an error is much better than emitting log messages,
always.
