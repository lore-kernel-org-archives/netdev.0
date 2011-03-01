From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 1 Mar 2011 13:45:29 +0800
Message-ID: <AANLkTi=MQoEKY5OLLN6f8-N7eD--Q6hL99HFFTAGU_Y4@mail.gmail.com>
References: <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
 <AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
 <1298631127.2659.22.camel@edumazet-laptop> <20110225.103456.226779149.davem@davemloft.net>
 <1298659538.2659.103.camel@edumazet-laptop> <1298659663.2659.104.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net, mirqus@gmail.com,
	ratbert@faraday-tech.com, Ajit Khaparde <ajit.khaparde@emulex.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298659663.2659.104.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Sat, Feb 26, 2011 at 2:47 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 19:45 +0100, Eric Dumazet a =C3=
=A9crit :
>> Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 10:34 -0800, David Miller a =
=C3=A9crit :
>> > From: Eric Dumazet <eric.dumazet@gmail.com>
>> > Date: Fri, 25 Feb 2011 11:52:07 +0100
>> >
>> > > Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 17:45 +0800, Po-Yu Chuan=
g a =C3=A9crit :
>> > >
>> > >> It's a little faster than v5 now. Thanks.
>> > >> I will submit the current version later.
>> > >>
>> > >> One more question just curious, why 128 bytes?
>> > >
>> > > Probably its best for NIU hardware specs
>> > >
>> > > You could try 64, as it should be enough for most IP/TCP/UDP pro=
cessing.
>> >
>> > IPV6.
>>
>> drivers/net/benet/be.h:70:#define BE_HDR_LEN =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A064
>>
>> Maybe we should have a comment somewhere.
>>
>> CC Ajit Khaparde <ajit.khaparde@emulex.com>
>>
>
>
> A compromise would be to use 128 for the allocation, but only copy 64
> bytes.

I will use this way and submit v7 later.

Thanks,
Po-Yu Chuang
