From: Erez Shitrit <erezsh@dev.mellanox.co.il>
Subject: Re: Re: [PATCH net] gro: fix aggregation for skb using frag_list
Date: Tue, 30 Sep 2014 14:51:49 +0300
Message-ID: <542A9955.9010609@dev.mellanox.co.il>
References: <1412012069.30721.31.camel@edumazet-glaptop2.roam.corp.google.com> <20140929.151900.618302492132612563.davem@davemloft.net> <07015a18f26f49518ceeabb35f2539ee@DB3PR05MB441.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: erezsh@mellanox.com, davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:39026 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbaI3Lvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 07:51:54 -0400
Received: by mail-we0-f178.google.com with SMTP id k48so27782wev.9
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 04:51:53 -0700 (PDT)
In-Reply-To: <07015a18f26f49518ceeabb35f2539ee@DB3PR05MB441.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, September 29, 2014 10:19 PM
> To: eric.dumazet@gmail.com
> Cc: netdev@vger.kernel.org; Erez Shitrit
> Subject: Re: [PATCH net] gro: fix aggregation for skb using frag_list
>
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 29 Sep 2014 10:34:29 -0700
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> In commit 8a29111c7ca6 ("net: gro: allow to build full sized skb") I
>> added a regression for linear skb that traditionally force GRO to use
>> the frag_list fallback.
>>
>> Erez Shitrit found that at most two segments were aggregated and the
>> "if (skb_gro_len(p) != pinfo->gso_size)" test was failing.
>>
>> This is because pinfo at this spot still points to the last skb in the
>> chain, instead of the first one, where we find the correct gso_size
>> information.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
>> Reported-by: Erez Shitrit <erezsh@mellanox.com>
> Applied and queued up for -stable, thanks Eric.
>
Tested. and it works for IPoIB driver. Thanks Eric.

Erez
