From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Thu, 16 May 2013 10:59:25 +0200
Message-ID: <CAHXqBFL8t9SUz3SXVonf+MwtVHU6UgAuk07ysGdPU7hGH8DbmQ@mail.gmail.com>
References: <1368654065.4519.53.camel@edumazet-glaptop> <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
 <1368659900.4519.57.camel@edumazet-glaptop> <1368660613.4519.60.camel@edumazet-glaptop>
 <CAHXqBFLnPQnd2a17B4_UKpiL70BzkFMWzocM-4mr88TYoG6Jcw@mail.gmail.com> <1368684572.3301.14.camel@edumazet-glaptop>
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
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34440 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785Ab3EPI7p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 04:59:45 -0400
Received: by mail-ie0-f175.google.com with SMTP id s9so5807576iec.20
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 01:59:45 -0700 (PDT)
In-Reply-To: <1368684572.3301.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/5/16 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2013-05-16 at 07:45 +0200, Micha=C5=82 Miros=C5=82aw wrote:
>
>> This should enable GSO if at least one slave has it on. What feature=
s
>> (tx-tcp*) the slaves have?
>
> Both slaves have tso off, gso on.
>
> (Let's say for some tricky hardware bug on the NIC)
>
> We want to not do tso on the NIC, but do the GSO segmentation right
> before NIC.
>
> It brings about 30% improvement.

Then your patch is the way to go.

BTW, the fix_features callbacks of bridge, team and bonding are so
similar it calls for some refactoring. What they want also seems very
close.

Best Regards,
Micha=C5=82 Miros=C5=82aw
