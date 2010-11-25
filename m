From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 13:35:30 +0500
Message-ID: <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	<1290666501.2798.84.camel@edumazet-laptop>
	<AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	<1290668246.2798.93.camel@edumazet-laptop>
	<AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
	<AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
	<1290672978.2798.151.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43576 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762Ab0KYIfb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 03:35:31 -0500
Received: by bwz15 with SMTP id 15so634653bwz.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 00:35:30 -0800 (PST)
In-Reply-To: <1290672978.2798.151.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

quick and dirty fix will be not to allow to pass unix socket inside
unix socket. I think it would not break much applications.

2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 25 novembre 2010 =C3=A0 12:52 +0500, =D0=9C=D0=B0=D1=80=D0=BA=
 =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
>> ---------- Forwarded message ----------
>> From: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=
=B5=D1=80=D0=B3 <socketpair@gmail.com>
>> Date: 2010/11/25
>> Subject: Re: Simple kernel attack using socketpair. easy, 100%
>> reproductiblle, works under guest. no way to protect :(
>> To: Eric Dumazet <eric.dumazet@gmail.com>
>>
>>
>> 2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
>> > Le jeudi 25 novembre 2010 =C3=A0 11:52 +0500, =D0=9C=D0=B0=D1=80=D0=
=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit=
 :
>> >> Well, It seems, that patch likely will fix 100% CPU usage.
>> >>
>> >> But what about eating all available descriptors in kernel ? vulne=
rability ?
>> >>
>> >
>> > It doesnt fix cpu usage actually, your program eats 100% of one cp=
u,
>> > like the following one :
>> >
>> > for (;;) ;
>> >
>> > If you want not eat 100% cpu, I suggest you add some blocking call=
s,
>> > like usleep(10000)
>> >
>> > for (;;) usleep(10000);
>> >
>> > Patch only makes sure kernel wont eat too much memory to store inf=
light
>> > unix sockets.
>>
>> I have attached source which proove, that loop not inside this
>> program, but inside kernel.
>>
>> --
>
> Better send a fix, now that thousand of people know how to kill a lin=
ux
> machine.
>
> Congrats.
>
>
>
>



--=20
Segmentation fault
