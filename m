From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Thu, 16 May 2013 07:45:05 +0200
Message-ID: <CAHXqBFLnPQnd2a17B4_UKpiL70BzkFMWzocM-4mr88TYoG6Jcw@mail.gmail.com>
References: <1368654065.4519.53.camel@edumazet-glaptop> <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
 <1368659900.4519.57.camel@edumazet-glaptop> <1368660613.4519.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f177.google.com ([209.85.210.177]:47585 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108Ab3EPFp0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 01:45:26 -0400
Received: by mail-ia0-f177.google.com with SMTP id z13so3101823iaz.36
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 22:45:26 -0700 (PDT)
In-Reply-To: <1368660613.4519.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/16 Eric Dumazet <eric.dumazet@gmail.com>:
> On Wed, 2013-05-15 at 16:18 -0700, Eric Dumazet wrote:
>> On Thu, 2013-05-16 at 00:55 +0200, Micha=C5=82 Miros=C5=82aw wrote:
>>
>> > Have you tried adding it to NETIF_F_ONE_FOR_ALL set? 'Team' and br=
idge
>> > could then also use it.
>>
>> Good point, I am testing this, thanks !
> Hmm, this doesnt work.
>
> # ethtool -k bond0 | grep tcp-segmentation-offload
> tcp-segmentation-offload: off
> # ethtool -K bond0 tso on
> # ethtool -k bond0 | grep tcp-segmentation-offload
> tcp-segmentation-offload: off
>
> Do you have something different in mind ?

This should enable GSO if at least one slave has it on. What features
(tx-tcp*) the slaves have?

Best Regards,
Micha=C5=82 Miros=C5=82aw
