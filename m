From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use SACK RTTs for CC
Date: Sat, 31 Jan 2015 17:26:01 -0800 (PST)
Message-ID: <20150131.172601.384724758739744851.davem@davemloft.net>
References: <1422558483-6168-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kennetkl@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbbBAB0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 20:26:02 -0500
In-Reply-To: <1422558483-6168-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Date: Thu, 29 Jan 2015 20:08:03 +0100

> Current behavior only passes RTTs from sequentially acked data to CC.
> 
> If sender gets a combined ACK for segment 1 and SACK for segment 3, then the
> computed RTT for CC is the time between sending segment 1 and receiving SACK
> for segment 3.
> 
> Pass the minimum computed RTT from any acked data to CC, i.e. time between
> sending segment 3 and receiving SACK for segment 3.
> 
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>

Applied, thanks.
