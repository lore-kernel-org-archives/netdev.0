From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: don't accept node local multicast traffic
 from the wire
Date: Fri, 29 Mar 2013 14:57:47 -0400 (EDT)
Message-ID: <20130329.145747.957517350887911269.davem@davemloft.net>
References: <20130326181334.GH29705@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, erik.hugne@ericsson.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756599Ab3C2S5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 14:57:49 -0400
In-Reply-To: <20130326181334.GH29705@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 26 Mar 2013 19:13:34 +0100

> Erik Hugne's errata proposal (Errata ID: 3480) to RFC4291 has been
> verified: http://www.rfc-editor.org/errata_search.php?eid=3480
> 
> We have to check for pkt_type and loopback flag because either the
> packets are allowed to travel over the loopback interface (in which case
> pkt_type is PACKET_HOST and IFF_LOOPBACK flag is set) or they travel
> over a non-loopback interface back to us (in which case PACKET_TYPE is
> PACKET_LOOPBACK and IFF_LOOPBACK flag is not set).
> 
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
