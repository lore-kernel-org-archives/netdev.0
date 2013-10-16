From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: remove redundant code in __tcp_retransmit_skb()
Date: Wed, 16 Oct 2013 13:34:10 -0400
Message-ID: <CAK6E8=cW93nE9x-=_qvvA02rMgT5+AqRj56yb+h6SfU9GOacfg@mail.gmail.com>
References: <1381941411-30645-1-git-send-email-ncardwell@google.com> <1381941843.2045.132.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:53236 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760963Ab3JPRec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 13:34:32 -0400
Received: by mail-ie0-f175.google.com with SMTP id aq17so1858914iec.6
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 10:34:31 -0700 (PDT)
In-Reply-To: <1381941843.2045.132.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 12:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-10-16 at 12:36 -0400, Neal Cardwell wrote:
>> Remove the specialized code in __tcp_retransmit_skb() that tries to trim
>> any ACKed payload preceding a FIN before we retransmit (this was added
>> in 1999 in v2.2.3pre3). This trimming code was made unreachable by the
>> more general code added above it that uses tcp_trim_head() to trim any
>> ACKed payload, with or without a FIN (this was added in "[NET]: Add
>> segmentation offload support to TCP." in 2002 circa v2.5.33).
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Yuchung Cheng <ycheng@google.com>
>> ---
>>  net/ipv4/tcp_output.c | 15 ---------------
>>  1 file changed, 15 deletions(-)
>
> Acked-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
>
>
