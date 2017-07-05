From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 11/12] net: Remove all references to SKB_GSO_UDP.
Date: Wed, 5 Jul 2017 12:27:11 -0400
Message-ID: <CAF=yD-KtJCyYqLDWv0pa7dcaJ=W8HM4eUnnwz8LJj_+S4U3-ZA@mail.gmail.com>
References: <20170705.160632.1021185732937441107.davem@davemloft.net> <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34108 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbdGEQ1w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 12:27:52 -0400
Received: by mail-oi0-f47.google.com with SMTP id l130so130764793oib.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 09:27:52 -0700 (PDT)
In-Reply-To: <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>         __be16 new_protocol, bool is_ipv6)
>
> In this file, can now remove all of udp4_ufo_fragment, and
> udp6_ufo_fragment in net/ipv6.

I had missed that this is used for tunneling with skb_udp_tunnel_segment.
But the core codepath should no longer be hit once SKB_GSO_UDP
is removed.
