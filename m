From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH V2] net: fix divide by zero in tcp algorithm
 illinois
Date: Thu, 01 Nov 2012 11:56:29 -0400 (EDT)
Message-ID: <20121101.115629.370549613464282212.davem@davemloft.net>
References: <20121031124318.30915.32293.stgit@dragon>
	<1351703678.32673.414.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, pmatouse@redhat.com,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936003Ab2KAP4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:56:34 -0400
In-Reply-To: <1351703678.32673.414.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 31 Oct 2012 18:14:38 +0100

> On Wed, 2012-10-31 at 13:45 +0100, Jesper Dangaard Brouer wrote:
>> Reading TCP stats when using TCP Illinois congestion control algorithm
>> can cause a divide by zero kernel oops.
>> 
>> The division by zero occur in tcp_illinois_info() at:
>>  do_div(t, ca->cnt_rtt);
>> where ca->cnt_rtt can become zero (when rtt_reset is called)
>> 
> 
>> Cc: Petr Matousek <pmatouse@redhat.com>
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> 
>> ---
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
