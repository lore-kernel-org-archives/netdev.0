From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Error in calculation of RTTvar
Date: Wed, 28 Nov 2012 11:13:54 -0500 (EST)
Message-ID: <20121128.111354.177489902452717372.davem@davemloft.net>
References: <1354115909-24172-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553Ab2K1QN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:13:57 -0500
In-Reply-To: <1354115909-24172-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: vyasevich@gmail.com
Date: Wed, 28 Nov 2012 10:18:29 -0500

> From: Schoch Christian <e0326715@student.tuwien.ac.at>
> 
> The calculation of RTTVAR involves the subtraction of two unsigned
> numbers which
> may causes rollover and results in very high values of RTTVAR when RTT > SRTT.
> With this patch it is possible to set RTOmin = 1 to get the minimum of RTO at
> 4 times the clock granularity.
> 
> Change Notes:
> 
> v2)
>         *Replaced abs() by abs64() and long by __s64, changed patch
> description.
> 
> Signed-off-by: Christian Schoch <e0326715@student.tuwien.ac.at>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: Sridhar Samudrala <sri@us.ibm.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: linux-sctp@vger.kernel.org
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
