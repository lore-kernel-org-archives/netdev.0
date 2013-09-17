From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix RTO calculated from cached RTT
Date: Tue, 17 Sep 2013 19:08:56 -0400 (EDT)
Message-ID: <20130917.190856.2130564126373837332.davem@davemloft.net>
References: <1379382260-29303-1-git-send-email-ncardwell@google.com>
	<CAK6E8=f5uMe6LQ5StCtaWt7D7PfaM2it0muxiW+gAZ4ngQwVbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343Ab3IQXJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 19:09:02 -0400
In-Reply-To: <CAK6E8=f5uMe6LQ5StCtaWt7D7PfaM2it0muxiW+gAZ4ngQwVbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue, 17 Sep 2013 07:32:38 -0700

> On Mon, Sep 16, 2013 at 6:44 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> Commit 1b7fdd2ab5852 ("tcp: do not use cached RTT for RTT estimation")
>> did not correctly account for the fact that crtt is the RTT shifted
>> left 3 bits. Fix the calculation to consistently reflect this fact.
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Yuchung Cheng <ycheng@google.com>
>> ---
>>  net/ipv4/tcp_metrics.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
> Acked-By: Yuchung Cheng <ycheng@google.com>
> 
> Thanks for discovering and fixing it!

Applied, thanks everyone.
