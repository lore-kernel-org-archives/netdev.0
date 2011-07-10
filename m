From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sun, 10 Jul 2011 10:58:23 +0200
Message-ID: <CAHXqBFLD0x5F0jOMqKfVSi8AJ+94dV2P_Wx_2DtOPOGC=aG6nA@mail.gmail.com>
References: <20110704142153O.fujita.tomonori@lab.ntt.co.jp>
 <20110703.223448.458910310802724750.davem@davemloft.net> <CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, fujita.tomonori@lab.ntt.co.jp,
	thockin@hockin.org, netdev@vger.kernel.org
To: Jim Cromie <jim.cromie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:60186 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629Ab1GJI6q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2011 04:58:46 -0400
Received: by qwk3 with SMTP id 3so1479243qwk.19
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 01:58:45 -0700 (PDT)
In-Reply-To: <CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/9 Jim Cromie <jim.cromie@gmail.com>:
> On Sun, Jul 3, 2011 at 11:34 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>> Date: Mon, 4 Jul 2011 14:30:19 +0900
>>
>>> This silences dma-debug warnings:
>>>
>>> https://lkml.org/lkml/2011/6/30/341
>> =C2=A0...
>>> Reported-by: Jim Cromie <jim.cromie@gmail.com>
>>> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>> Tested-by: Jim Cromie <jim.cromie@gmail.com>
>>
>> Applied, thanks!
>>
>
> I have since seen a similar warning on shutdown,
> heres a patch for it.
>
> theres one other callsite, but I havent seen the warning from it,
> will try to tickle it at some point.

[about attached patch]

Why not increase buflen, like in refill_rx()?

Best Regards,
Micha=C5=82 Miros=C5=82aw
