From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 4/4] udp: Move udp_tunnel_segment into udp_offload.c
Date: Mon, 14 Jul 2014 13:14:45 -0700
Message-ID: <CA+mtBx-j81E_WZsSN51Hn-k9G6FmC-kVLbxgg0hEtXSpMtLKrw@mail.gmail.com>
References: <alpine.DEB.2.02.1407131940460.24734@tomh.mtv.corp.google.com>
	<1405329093.10255.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:43261 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756879AbaGNUOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 16:14:46 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so3737633iec.16
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 13:14:46 -0700 (PDT)
In-Reply-To: <1405329093.10255.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2014 at 2:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-07-13 at 19:49 -0700, Tom Herbert wrote:
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index 546d2d4..4807544 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -47,6 +47,82 @@ static int udp4_ufo_send_check(struct sk_buff *skb)
>>       return 0;
>>  }
>>
>> +struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>> +                                    netdev_features_t features)
>> +{
>
>
> Hmm. Looks like skb_udp_tunnel_segment() should be static then ?
>
It's also called from net/ipv6/udp_offload.c

>
