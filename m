From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Fri, 27 May 2011 09:56:44 +0200
Message-ID: <4DDF593C.3060900@univ-nantes.fr>
References: <201104250033.03401.maxi@daemonizer.de>	 <1303878240.2699.41.camel@edumazet-laptop>	 <1303878771.2699.44.camel@edumazet-laptop>	 <201104271352.00601.maxi@daemonizer.de>	 <20110512211033.GA3468@dev1756.snc6.facebook.com>	 <1305234953.2831.2.camel@edumazet-laptop>	 <20110524213327.GA3917@dev1756.snc6.facebook.com>	 <1306291469.3305.11.camel@edumazet-laptop>	 <20110525060609.GA32244@dev1756.snc6.facebook.com>	 <1306305331.3305.22.camel@edumazet-laptop>  <4DDEAA3C.7020502@fb.com>	 <1306439246.2543.10.camel@edumazet-laptop>  <4DDECA9B.8080206@fb.com>	 <1306447292.2543.32.camel@edumazet-laptop>  <4DDEEBC5.80804@fb.com> <1306466831.2543.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arun Sharma <asharma@fb.com>, David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Denys Fedoryshchenko <denys@visp.net.lb>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306466831.2543.58.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 27/05/2011 05:27, Eric Dumazet a =C3=A9crit :
> Le jeudi 26 mai 2011 =C3=A0 17:09 -0700, Arun Sharma a =C3=A9crit :
>> On 5/26/11 3:01 PM, Eric Dumazet wrote:
>>
>>
>>>> Yeah - using the refcnt seems better than list_empty(), but I'm no=
t sure
>>>> that your patch addresses the race above.
>>> It does.
>> True. I can't find any holes in this method and it resolves the "fai=
lure
>> to unlink from unused" case.
>>
>> Perhaps wrap the while(1) loop into its own primitive in atomic.h or=
 use
>> an existing primitive?
>>
> Sure, here is a formal submission I cooked.
>
> Thanks
>
> [PATCH] inetpeer: fix race in unused_list manipulations

Thanks eric, didn't noticed this thread, nice to see you squashed this =
bug.
As you said in a previous message, slub_nomerge prevented us from=20
crashing for 113 days now :)

But of course, THE REAL FIX is much preffered. Will try this patch with=
=20
the next -stable update.

Thanks for your efforts,

--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr
