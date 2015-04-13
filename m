From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix bogus RTT for CC when
 retransmissions are acked
Date: Mon, 13 Apr 2015 13:55:06 -0400 (EDT)
Message-ID: <20150413.135506.1156687955230440884.davem@davemloft.net>
References: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kennetkl@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbbDMRzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:55:08 -0400
In-Reply-To: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Date: Sat, 11 Apr 2015 02:17:49 +0200

> Since retransmitted segments are not used for RTT estimation, previously
> SACKed segments present in the rtx queue are used. This estimation can be
> several times larger than the actual RTT. When a cumulative ack covers both
> previously SACKed and retransmitted segments, CC may thus get a bogus RTT.
> 
> Such segments previously had an RTT estimation in tcp_sacktag_one(), so it
> seems reasonable to not reuse them in tcp_clean_rtx_queue() at all.
> 
> Afaik, this has had no effect on SRTT/RTO because of Karn's check.
> 
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Applied, thanks.
