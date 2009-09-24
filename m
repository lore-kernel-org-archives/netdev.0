From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pktgen: better scheduler friendliness
Date: Thu, 24 Sep 2009 15:44:53 -0700 (PDT)
Message-ID: <20090924.154453.230710626.davem@davemloft.net>
References: <20090923054141.932043798@vyatta.com>
	<20090923054201.520300835@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751105AbZIXWof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 18:44:35 -0400
In-Reply-To: <20090923054201.520300835@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 22 Sep 2009 22:41:43 -0700

> Previous update did not resched in inner loop causing watchdogs.
> Rewrite inner loop to:
>   * account for delays better with less clock calls
>   * more accurate timing of delay:
>     - only delay if packet was successfully sent
>     - if delay is 100ns and it takes 10ns to build packet then
>       account for that
>   * use wait_event_interruptible_timeout rather than open coding it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
