From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] bridge: Fix problems around the PVID
Date: Thu, 12 Sep 2013 16:00:33 -0400 (EDT)
Message-ID: <20130912.160033.779509034953932316.davem@davemloft.net>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161Ab3ILUAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 16:00:36 -0400
In-Reply-To: <1378808874.3988.2.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 10 Sep 2013 19:27:54 +0900

> There seem to be some undesirable behaviors related with PVID.
> 1. It has no effect assigning PVID to a port. PVID cannot be applied
> to any frame regardless of whether we set it or not.
> 2. FDB entries learned via frames applied PVID are registered with
> VID 0 rather than VID value of PVID.
> 3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
> This leads interoperational problems such as sending frames with VID
> 4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
> 0 as they belong to VLAN 0, which is expected to be handled as they have
> no VID according to IEEE 802.1Q.
> 
> Note: 2nd and 3rd problems are potential and not exposed unless 1st problem
> is fixed, because we cannot activate PVID due to it.

Please work out the issues in patch #2 with Vlad and resubmit this
series.

Thank you.
