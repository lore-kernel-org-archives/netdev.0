From: David Miller <davem@davemloft.net>
Subject: Re: [RFC davem] revert: net: Make skb->skb_iif always track
 skb->dev
Date: Sun, 13 Jan 2013 08:20:34 -0500 (EST)
Message-ID: <20130113.082034.1900325629672858177.davem@davemloft.net>
References: <20130112.132316.2121287993605534669.davem@davemloft.net>
	<20130112.133630.257139657732337147.davem@davemloft.net>
	<50F29421.1090405@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41394 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027Ab3AMNUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 08:20:36 -0500
In-Reply-To: <50F29421.1090405@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Sun, 13 Jan 2013 12:01:53 +0100

> Networking is not only IP networking.

But it is who the majority of the infrastructure is goint to be
optimized for, and this is never going to change.
