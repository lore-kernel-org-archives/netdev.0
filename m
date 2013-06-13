From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: properly send new data in fast recovery
 in first RTT
Date: Thu, 13 Jun 2013 02:47:15 -0700 (PDT)
Message-ID: <20130613.024715.260290333100191694.davem@davemloft.net>
References: <1370990132-27652-1-git-send-email-ycheng@google.com>
	<CADVnQymM_fasoZ6s=Si=gccQ=wvmdt+0jryWovTxLeZw8e95WA@mail.gmail.com>
	<1371009475.3252.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, ycheng@google.com, edumazet@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757543Ab3FMJrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:47:15 -0400
In-Reply-To: <1371009475.3252.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 11 Jun 2013 20:57:55 -0700

> On Tue, 2013-06-11 at 19:56 -0400, Neal Cardwell wrote:
>> On Tue, Jun 11, 2013 at 6:35 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> > Linux sends new unset data during disorder and recovery state if all
>> > (suspected) lost packets have been retransmitted ( RFC5681, section
>> > 3.2 step 1 & 2, RFC3517 section 4, NexSeg() Rule 2).  One requirement
>> > is to keep the receive window about twice the estimated sender's
>> > congestion window (tcp_rcv_space_adjust()), assuming the fast
>> > retransmits repair the losses in the next round trip.
>> >
>> > But currently it's not the case on the first round trip in either
>> > normal or Fast Open connection, beucase the initial receive window
>> > is identical to (expected) sender's initial congestion window. The
>> > fix is to double it.
>> >
>> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> 
>> Acked-by: Neal Cardwell <ncardwell@google.com>
> 
> Yes, this is indeed a very nice catch, thanks Yuchung !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
