From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reorganize IP MIB values
Date: Sat, 11 Aug 2012 18:19:33 -0700 (PDT)
Message-ID: <20120811.181933.1068299387076668064.davem@davemloft.net>
References: <1344148439.9299.1570.camel@edumazet-glaptop>
	<20120811134219.4a3b146d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab2HLBTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2012 21:19:37 -0400
In-Reply-To: <20120811134219.4a3b146d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 11 Aug 2012 13:42:19 -0700

> Will this break kernel ABI since these are exported in sanitized headers?

No, the tools parse the field names from the procfs output.
