From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: debugging kernel during packet drops
Date: Thu, 25 Mar 2010 13:42:00 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003251338240.27347@obet.zrqbmnf.qr>
References: <4BA74950.6000305@infopact.nl> <4BA7A5D8.5080101@trash.net>  <4BA8DAC5.6050002@infopact.nl> <1269364893.2983.296.camel@edumazet-laptop>  <4BAA2DC5.7000409@infopact.nl>  <1269447674.3213.64.camel@edumazet-laptop> <1269509574.3626.9.camel@edumazet-laptop>
 <4BAB3C8B.3030104@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jorrit Kronjee <j.kronjee@infopact.nl>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BAB3C8B.3030104@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-03-25 11:35, Patrick McHardy wrote:
>Eric Dumazet wrote:
>> Here is patch I cooked for xt_hashlimit (on top of net-next-2.6) to make
>> it use RCU and scale better in your case (allowing several concurrent
>> cpus once RPS is activated), but also on more general cases.
>> 
>> [PATCH] xt_hashlimit: RCU conversion
>
>This clashes with some recent cleanups in nf-next-2.6.git. I'm
>also expecting a patch from Jan to remove the old v0 revision
>very soon (probably today).

I was waiting for you to process
http://marc.info/?l=netfilter-devel&m=126936212932683&w=2
which is a prerequisite for the hashlimit v0 removal.
(I expected that you might miss some mails due to trash.net
having been down yesterday. No biggie.)
