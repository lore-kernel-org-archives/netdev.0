From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 2/5] niu: fix 64 bit statistics on 32 bit
 platform
Date: Mon, 20 Jun 2011 14:52:01 -0700
Message-ID: <20110620145201.42dd9bf8@nehalam.ftrdhcpuser.net>
References: <20110620203506.363818794@vyatta.com>
	<20110620203602.739916889@vyatta.com>
	<1308606356.2701.199.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53468 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755167Ab1FTVwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 17:52:03 -0400
In-Reply-To: <1308606356.2701.199.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> It looks like you also need to update release_tx_packet() where these
> stats are written.

Probably need to split tx/rx update as well.
