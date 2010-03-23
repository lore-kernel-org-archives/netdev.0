From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: make distributing packets fairly among all the
	online CPUs default
Date: Tue, 23 Mar 2010 19:27:45 +0800
Message-ID: <412e6f7f1003230427t1cf0f1e6t402f6c7cc542c62f@mail.gmail.com>
References: <4BA85EA2.1090304@gmail.com> <1269328852.3043.13.camel@edumazet-laptop>
	<412e6f7f1003230256m109644b0n2988e86a56f1ae1@mail.gmail.com>
	<1269343422.2983.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:65464 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab0CWL2F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 07:28:05 -0400
Received: by mail-iw0-f176.google.com with SMTP id 6so1655868iwn.4
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 04:28:05 -0700 (PDT)
In-Reply-To: <1269343422.2983.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 23, 2010 at 7:23 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 23 mars 2010 =C3=A0 17:56 +0800, Changli Gao a =C3=A9crit :
>> On Tue, Mar 23, 2010 at 3:20 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le mardi 23 mars 2010 =C3=A0 14:24 +0800, Changli Gao a =C3=A9crit=
 :
>> >
>> > You cannot do this like this, these allocations wont be freed.
>> >
>> > Better would be to take a look at net/core/net-sysfs.c
>> >
>>
>> Sorry, but I don't know why these allocations won't be freed.
>>
>>
>
> Hint : This will be freed only if CONFIG_SYSFS is set
>

got it, thanks. But I just wonder if it is right the life cycle of
rps_map is maintained by sysfs rather than netdev itself.



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
