From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink & bonding: change args got
 get_tx_queues
Date: Fri, 13 Apr 2012 13:31:20 -0400 (EDT)
Message-ID: <20120413.133120.864058193509597970.davem@davemloft.net>
References: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
	<1334009344.7150.268.camel@deadeye>
	<20120410213443.31fc0784@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2DMRcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 13:32:50 -0400
In-Reply-To: <20120410213443.31fc0784@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Apr 2012 21:34:43 -0700

> Change get_tx_queues, drop unsused arg/return value real_tx_queues,
> and use return by value (with error) rather than call by reference.
> 
> Probably bonding should just change to LLTX and the whole get_tx_queues
> API could disappear!
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
