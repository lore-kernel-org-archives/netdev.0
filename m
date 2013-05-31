From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: skbuff: use _RET_IP_
Date: Fri, 31 May 2013 18:33:08 +0400
Message-ID: <51A8B4A4.1010204@cogentembedded.com>
References: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>  <51A6768B.5050603@cogentembedded.com> <87obbsohd1.fsf@nemi.mork.no>  <1369962688.1751.6.camel@buesod1.americas.hpqcorp.net> <1369977659.10556.34.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>,
	=?ISO-8859-1?Q?Bj=F8rn_Mo?= =?ISO-8859-1?Q?rk?= <bjorn@mork.no>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:54724 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab3EaOdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 10:33:06 -0400
Received: by mail-lb0-f179.google.com with SMTP id r11so1765434lbv.10
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 07:33:04 -0700 (PDT)
In-Reply-To: <1369977659.10556.34.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 31-05-2013 9:20, Joe Perches wrote:

>>>>      Why not "text:%#lx" as already used in this string? It's
>>>> equivalent to "0x%lx".

>>> Well, I don't know the reasoning in this case, but I'd like to note that
>>> those are not strictly equivalent.  Personally I find the formatting of 0
>>> annoying enough to avoid %#x for any value which may be 0.  It's
>>> especially bad if you try to line up things by adding leading zeros.

>> Yep, I found that 0x%lx produced the same output as %p.

> Don't use a standalone gcc compiled program to
> determine what the kernel outputs.

> lib/vsprintf.c does not output the same. (32 bit)

> The kernel output is;

> 	printk("0x%lx\n", 0x100ul)		0x100
> 	printk("%p\n", (void *)0x100ul)		00000100
> 	printk("%#p\n", (void *)0x100ul)	0x00000100

> The last one isn't used at all in kernel source. (gcc complains)
> It's always "0x%p"

     I was talking about using "%#lx", not "%#p". I don't see it in your 
example.

WBR, Sergei
