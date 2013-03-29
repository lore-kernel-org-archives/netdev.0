From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Fri, 29 Mar 2013 15:33:05 -0400 (EDT)
Message-ID: <20130329.153305.1464690884667907437.davem@davemloft.net>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
	<1364569280.5113.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756616Ab3C2TdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:33:12 -0400
In-Reply-To: <1364569280.5113.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Mar 2013 08:01:20 -0700

> On Thu, 2013-03-28 at 16:52 -0700, Vijay Subramanian wrote:
>> Currently, we hold a max of sch->limit -1 number of packets instead of
>> sch->limit packets. Fix this off-by-one error.
>> 
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
