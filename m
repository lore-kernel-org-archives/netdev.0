From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ipv6: gro: support sit protocol
Date: Wed, 4 Nov 2015 06:14:14 +0900
Message-ID: <CALx6S35BK3aTGwceKmdXPDyGq+xn_ysb_yvgjj9piq2va30zFg@mail.gmail.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
	<1445306641.30896.42.camel@edumazet-glaptop2.roam.corp.google.com>
	<1445312417.30896.64.camel@edumazet-glaptop2.roam.corp.google.com>
	<19837690.PaPkekjCr9@stwm.de>
	<1446556053.23275.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	Jerry Chu <hkchu@google.com>, JesseGross <jesse@nicira.com>,
	netdev <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36683 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019AbbKCVOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:14:15 -0500
Received: by ioll68 with SMTP id l68so33366135iol.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 13:14:15 -0800 (PST)
In-Reply-To: <1446556053.23275.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 10:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2015-11-03 at 13:57 +0100, Wolfgang Walter wrote:
>> Am Montag, 19. Oktober 2015, 20:40:17 schrieb Eric Dumazet:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > Tom Herbert added SIT support to GRO with commit
>> > 19424e052fb4 ("sit: Add gro callbacks to sit_offload"),
>> > later reverted by Herbert Xu.
>> >
>> > The problem came because Tom patch was building GRO
>> > packets without proper meta data : If packets were locally
>> > delivered, we would not care.
>> >
>> > But if packets needed to be forwarded, GSO engine was not
>> > able to segment individual segments.
>> >
>> > With the following patch, we correctly set skb->encapsulation
>> > and inner network header. We also update gso_type.
>> >
>>
>> I'm running 4.1.11 / 4.1.12 with this patch on top now since over a week.
>> ISATAP works fine.
>
> Perfect ! thanks a lot for testing !
>

Thanks for all the work on this!

Tom

>
