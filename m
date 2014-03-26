From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: delete unused parameter in tcp_nagle_check()
Date: Wed, 26 Mar 2014 15:43:59 -0400 (EDT)
Message-ID: <20140326.154359.1226604668976262883.davem@davemloft.net>
References: <4609be8bb5dacb54d14e1b1f5dc8264b85c7c8d3.1395630957.git.panweiping3@gmail.com>
	<1395666527.12610.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbaCZToB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:44:01 -0400
In-Reply-To: <1395666527.12610.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Mar 2014 06:08:47 -0700

> On Mon, 2014-03-24 at 14:49 +0800, Weiping Pan wrote:
>> After commit d4589926d7a9 (tcp: refine TSO splits), tcp_nagle_check() does
>> not use parameter mss_now anymore.
>> 
>> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
>> ---
> 
> Its not a fix and should target net-next, otherwise it looks good to me.

Agreed, applied to net-next, thanks.
