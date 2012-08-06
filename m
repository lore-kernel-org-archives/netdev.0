From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: ecn: dont delay ACKS after CE
Date: Mon, 06 Aug 2012 14:14:51 -0700 (PDT)
Message-ID: <20120806.141451.191138983583413911.davem@davemloft.net>
References: <1344287083.26674.83.camel@edumazet-glaptop>
	<CADVnQyk25R4qpXq7Mho=uHwCswALPdOR=nP=AjQy7qJyT+HFuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab2HFVOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 17:14:55 -0400
In-Reply-To: <CADVnQyk25R4qpXq7Mho=uHwCswALPdOR=nP=AjQy7qJyT+HFuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 6 Aug 2012 17:07:08 -0400

> On Mon, Aug 6, 2012 at 5:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> While playing with CoDel and ECN marking, I discovered a
>> non optimal behavior of receiver of CE (Congestion Encountered)
>> segments.
>>
>> In pathological cases, sender has reduced its cwnd to low values,
>> and receiver delays its ACK (by 40 ms).
>>
>> While RFC 3168 6.1.3 (The TCP Receiver) doesn't explicitly recommend
>> to send immediate ACKS, we believe its better to not delay ACKS, because
>> a CE segment should give same signal than a dropped segment, and its
>> quite important to reduce RTT to give ECE/CWR signals as fast as
>> possible.
>>
>> Note we already call tcp_enter_quickack_mode() from TCP_ECN_check_ce()
>> if we receive a retransmit, for the same reason.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Neal Cardwell <ncardwell@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
