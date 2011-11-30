From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: inherit listener congestion control for
 passive cnx
Date: Wed, 30 Nov 2011 09:33:54 -0800
Message-ID: <4ED66902.3050309@hp.com>
References: <20111130003112.C04FE29005FE@tardy> <1322630461.2596.61.camel@edumazet-laptop> <1322631613.2596.70.camel@edumazet-laptop> <1322650961.2403.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <raj@tardy.cup.hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:4929 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756404Ab1K3Rd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 12:33:57 -0500
In-Reply-To: <1322650961.2403.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2011 03:02 AM, Eric Dumazet wrote:
> Le mercredi 30 novembre 2011 =C3=A0 06:40 +0100, Eric Dumazet a =C3=A9=
crit :
>> Le mercredi 30 novembre 2011 =C3=A0 06:21 +0100, Eric Dumazet a =C3=A9=
crit :
>>
>>> So my suggestion would be to use this two lines patch instead :
>>>
>>> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
>>> index 945efff..6b066e2 100644
>>> --- a/net/ipv4/tcp_minisocks.c
>>> +++ b/net/ipv4/tcp_minisocks.c
>>> @@ -495,8 +495,6 @@ struct sock *tcp_create_openreq_child(struct so=
ck *sk, struct request_sock *req,
>>>   		newtp->frto_counter =3D 0;
>>>   		newtp->frto_highmark =3D 0;
>>>
>>> -		newicsk->icsk_ca_ops =3D&tcp_init_congestion_ops;
>>> -
>>>   		tcp_set_ca_state(newsk, TCP_CA_Open);
>>>   		tcp_init_xmit_timers(newsk);
>>>   		skb_queue_head_init(&newtp->out_of_order_queue);
>>>
>>
>> Please test this change and if its OK, resubmit your patch, with
>> appropriate Documentation change, as pointed out by Yuchung Cheng
>
> Hmm, after taking more time on this, we have to take care of module
> refcounting and proper cleanup. I hope you dont mind I submit my fina=
l
> version of this patch.

I do not mind at all.

rick
