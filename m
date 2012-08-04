From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ppp: add 64 bit stats
Date: Fri, 03 Aug 2012 20:41:41 -0700 (PDT)
Message-ID: <20120803.204141.445487530122768077.davem@davemloft.net>
References: <1343446733-4791-1-git-send-email-kgroeneveld@gmail.com>
	<1343461141.2626.13122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kgroeneveld@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043Ab2HDDlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 23:41:42 -0400
In-Reply-To: <1343461141.2626.13122.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 28 Jul 2012 09:39:01 +0200

> On Fri, 2012-07-27 at 23:38 -0400, Kevin Groeneveld wrote:
>> Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
>> rx_bytes, tx_packets and rx_packets.  Other stats are still 32 bit.
>> The 64 bit stats can be retrieved via the ndo_get_stats operation.  The
>> SIOCGPPPSTATS ioctl is still 32 bit stats only.
>> 
>> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
>> ---
>> v2: - do not use percpu variables for stats
>>     - use ppp_recv_lock/ppp_xmit_lock when reading 64 bit stats
>> 
> 
> Seems fine to me this time ;)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
