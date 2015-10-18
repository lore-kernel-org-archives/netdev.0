From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 2/7] tcp: track min RTT using windowed min-filter
Date: Sun, 18 Oct 2015 10:33:41 -0400
Message-ID: <CADVnQyk1e+csk_kX3D+E2CCeBi3sAKGjePEn3bAWceVFNf02Fg@mail.gmail.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
	<1445057867-32257-3-git-send-email-ycheng@google.com>
	<20151014092800.GA3748@mininet-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Andrew Shewmaker <agshew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36452 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbbJROdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 10:33:42 -0400
Received: by obcqt19 with SMTP id qt19so43547872obc.3
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 07:33:42 -0700 (PDT)
In-Reply-To: <20151014092800.GA3748@mininet-vm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 5:28 AM, Andrew Shewmaker <agshew@gmail.com> wrote:
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 38743e5..e177386 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
> ...
>> @@ -2961,7 +3028,7 @@ void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
>>               rtt_us = skb_mstamp_us_delta(&now, &tcp_rsk(req)->snt_synack);
>>       }
>>
>> -     tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L);
>> +     tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L, rtt_us);
>>  }
>
> This didn't apply to net-next for me. I see seq_rtt_us instead of
> rtt_us and a check on the existence of tp->srtt_us. Maybe I've
> misapplied the patch?

This patch series applies cleanly for me against David Miller's
net-next at SHA1 4be3158 (from Friday Oct 16). (Using "git am" on the
mbox patches from http://patchwork.ozlabs.org/project/netdev/list/
...)

On top of what SHA1 are you applying the series?

neal
