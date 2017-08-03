From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid setting cwnd to invalid ssthresh after
 cwnd reduction states
Date: Thu, 03 Aug 2017 09:30:03 -0700 (PDT)
Message-ID: <20170803.093003.630342740216225722.davem@davemloft.net>
References: <20170801202232.162176-1-ycheng@google.com>
        <20170802.105136.1599120748083773522.davem@davemloft.net>
        <CAK6E8=ft9MQq5BJ_GwguHLoAXMyBWzJDBi4JMthY9PWEGxd3rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbdHCQaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:30:04 -0400
In-Reply-To: <CAK6E8=ft9MQq5BJ_GwguHLoAXMyBWzJDBi4JMthY9PWEGxd3rA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 2 Aug 2017 10:58:54 -0700

> On Wed, Aug 2, 2017 at 10:51 AM, David Miller <davem@davemloft.net> wrote:
>>
>> From: Yuchung Cheng <ycheng@google.com>
>> Date: Tue,  1 Aug 2017 13:22:32 -0700
>>
>> > If the sender switches the congestion control during ECN-triggered
>> > cwnd-reduction state (CA_CWR), upon exiting recovery cwnd is set to
>> > the ssthresh value calculated by the previous congestion control. If
>> > the previous congestion control is BBR that always keep ssthresh
>> > to TCP_INIFINITE_SSTHRESH, cwnd ends up being infinite. The safe
>> > step is to avoid assigning invalid ssthresh value when recovery ends.
>> >
>> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> > Signed-off-by: Neal Cardwell <ncardwell@google.com>
>>
>> Applied, thanks.
>>
>> Is this a -stable candidate?
> 
> Yes it is. Thanks!

Great, queued up.
