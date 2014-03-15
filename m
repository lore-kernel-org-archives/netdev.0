From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/16] Don't receive packets when the napi
 budget == 0
Date: Fri, 14 Mar 2014 22:54:01 -0400 (EDT)
Message-ID: <20140314.225401.1475848510205014871.davem@davemloft.net>
References: <20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com>
	<871ty41dps.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391AbaCOCyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 22:54:03 -0400
In-Reply-To: <871ty41dps.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 14 Mar 2014 17:56:47 -0700

> After reading through all 120 drivers supporting netpoll I have found 16
> more that process at least received packet when the napi budget == 0.
> 
> Processing more packets than your budget has always been a bug but
> we haven't cared before so it looks like these drivers slipped through,
> and need fixes.
> 
> As netpoll will shortly be using a budget of 0 to get the tx queue
> processing with the rx queue processing we now care.

Series applied, thanks Eric.
