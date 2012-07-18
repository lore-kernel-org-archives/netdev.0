From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] b44: add 64 bit stats
Date: Wed, 18 Jul 2012 09:30:00 -0700 (PDT)
Message-ID: <20120718.093000.179327365392766204.davem@davemloft.net>
References: <20120716.230806.242760837075045729.davem@davemloft.net>
	<1342583161-1184-1-git-send-email-kgroeneveld@gmail.com>
	<1342583402.2626.1376.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kgroeneveld@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898Ab2GRQaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:30:01 -0400
In-Reply-To: <1342583402.2626.1376.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 05:50:02 +0200

> On Tue, 2012-07-17 at 23:46 -0400, Kevin Groeneveld wrote:
>> From: Kevin Groeneveld <kgroeneveld@gmail.com>
>> 
>> Add support for 64 bit stats to Broadcom b44 ethernet driver.
>> 
>> Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
>> ---
>> v2: use u64_stats_fetch_begin_bh/u64_stats_fetch_retry_bh instead of
>>     u64_stats_fetch_begin/u64_stats_fetch_retry as stats update happens in a
>>     timer interrupt
> 
> Seems good this time, thanks
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
