From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v2 net-next 1/4] tcp: consolidate SYNACK RTT sampling
Date: Tue, 23 Jul 2013 08:54:35 -0700
Message-ID: <CAK6E8=eO7Ktx0J+4QChiy09dJyoWdrL6+g53_d8+i-QCM9PynA@mail.gmail.com>
References: <1374535248-27418-1-git-send-email-ycheng@google.com> <20130722.180255.685921996264320731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:49192 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab3GWPy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 11:54:56 -0400
Received: by mail-ob0-f170.google.com with SMTP id ef5so10673689obb.29
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 08:54:55 -0700 (PDT)
In-Reply-To: <20130722.180255.685921996264320731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 6:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Mon, 22 Jul 2013 16:20:45 -0700
>
>> This patch series improve RTT sampling in three ways:
>> 1. Sample RTT during fast recovery and reordering events.
>> 2. Favor ack-based RTT to timestamps because of broken TS ECR fields
>> 3. Consolidate the RTT measurement logic.
>>
>> The first patch consolidates SYNACK and other RTT measurement to use a
>> central function tcp_ack_update_rtt(). A (small) bonus is now SYNACK
>> RTT measurement happens after PAWS check, potentially reducing the
>> impact of RTO seeding on bad TCP timestamps values.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>
> I like this series a lot, applied, thanks!
>
> Next time please submit a seperate "[PATCH 0/4] xxx" posting.
>
> If it has non-trivial content, I use the "0" posting as the
> commit message of a merge commit when I apply your series.
>
> What I did here was take the text:
>
> ====================
> This patch series improve RTT sampling in three ways:
> 1. Sample RTT during fast recovery and reordering events.
> 2. Favor ack-based RTT to timestamps because of broken TS ECR fields
> 3. Consolidate the RTT measurement logic.
> ====================
>
> and place it into that merge commit, removing it from the patch #1
> commit message.
Thank you David. Sorry for the extra hassle. Will definitely do that
for next patch series.

>
> Thanks.
