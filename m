From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: Re: Unix socket local DOS (OOM)
Date: Wed, 24 Nov 2010 00:25:32 +0100
Message-ID: <AANLkTimhCumpPDktqLF9c19DP8Eh3f8PP-89zeGfpHNM@mail.gmail.com>
References: <AANLkTi=Q967xpX0KLMwX-=_4_1AKO5wjHEuJ1TrNjCj9@mail.gmail.com>
	<1290553918.2866.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eugene Teo <eugene@redhat.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290553918.2866.80.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24 November 2010 00:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le mardi 23 novembre 2010 =C3=A0 23:21 +0100, Vegard Nossum a =C3=A9c=
rit :
>> Hi,
>>
>> I found this program lying around on my laptop. It kills my box
>> (2.6.35) instantly by consuming a lot of memory (allocated by the
>> kernel, so the process doesn't get killed by the OOM killer). As far
>> as I can tell, the memory isn't being freed when the program exits
>> either. Maybe it will eventually get cleaned up the UNIX socket
>> garbage collector thing, but in that case it doesn't get called
>> quickly enough to save my machine at least.

>
> Hi Vegard
>
> Do you have a patch to correct this problem ?

No, sorry, I didn't look into it.


Vegard
