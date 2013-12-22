From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: consistent reporting of pmtu data in case of
 corking
Date: Sun, 22 Dec 2013 18:52:34 -0500 (EST)
Message-ID: <20131222.185234.1072974003278388464.davem@davemloft.net>
References: <20131219011336.GB14429@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189Ab3LVXwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:52:36 -0500
In-Reply-To: <20131219011336.GB14429@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 19 Dec 2013 02:13:36 +0100

> We report different pmtu values back on the first write and on further
> writes on an corked socket.
> 
> Also don't include the dst.header_len (respectively exthdrlen) as this
> should already be dealt with by the interface mtu of the outgoing
> (virtual) interface and policy of that interface should dictate if
> fragmentation should happen.
> 
> Instead reduce the pmtu data by IP options as we do for IPv6. Make the
> same changes for ip_append_data, where we did not care about options or
> dst.header_len at all.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied, thanks.
