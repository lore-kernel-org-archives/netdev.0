From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Wed, 15 May 2013 23:09:32 -0700
Message-ID: <1368684572.3301.14.camel@edumazet-glaptop>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	 <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
	 <1368659900.4519.57.camel@edumazet-glaptop>
	 <1368660613.4519.60.camel@edumazet-glaptop>
	 <CAHXqBFLnPQnd2a17B4_UKpiL70BzkFMWzocM-4mr88TYoG6Jcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:62037 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866Ab3EPGJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 02:09:34 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa10so2199097pad.19
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 23:09:34 -0700 (PDT)
In-Reply-To: <CAHXqBFLnPQnd2a17B4_UKpiL70BzkFMWzocM-4mr88TYoG6Jcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-16 at 07:45 +0200, Micha=C5=82 Miros=C5=82aw wrote:

> This should enable GSO if at least one slave has it on. What features
> (tx-tcp*) the slaves have?

Both slaves have tso off, gso on.

(Let's say for some tricky hardware bug on the NIC)

We want to not do tso on the NIC, but do the GSO segmentation right
before NIC.

It brings about 30% improvement.
