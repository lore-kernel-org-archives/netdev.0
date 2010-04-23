From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Fri, 23 Apr 2010 09:55:50 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004230955030.26168@obet.zrqbmnf.qr>
References: <1271941082.14501.189.camel@jdb-workstation>  <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>  <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>  <1271948029.7895.5707.camel@edumazet-laptop>
 <20100422155123.GA2524@linux.vnet.ibm.com>  <1271952128.7895.5851.camel@edumazet-laptop>  <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>  <1271970199.7895.6482.camel@edumazet-laptop>  <Pine.LNX.4.64.1004222323020.11449@ask.diku.dk>
 <alpine.LSU.2.01.1004230922120.24961@obet.zrqbmnf.qr> <1272008780.7895.7746.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45592 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756300Ab0DWHzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 03:55:52 -0400
In-Reply-To: <1272008780.7895.7746.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 2010-04-23 09:46, Eric Dumazet wrote:

>Le vendredi 23 avril 2010 =C3=A0 09:23 +0200, Jan Engelhardt a =C3=A9c=
rit :
>> On Thursday 2010-04-22 23:28, Jesper Dangaard Brouer wrote:
>>=20
>> > On Thu, 22 Apr 2010, Eric Dumazet wrote:
>> >
>> >> What exact version of kernel are you running ?
>> >
>> > 2.6.31.7-pvlan2G #3 SMP PREEMPT
>> > 32-bit kernel with 2G kernel mem (you showed me that trick).
>>=20
>> Since when is enabling 2G a trick? :)
>> There's CONFIG_VMSPLIT_2G (and 2G_OPT) for quite some time now.
>>=20
>
>Yes, when you know it, its not a trick anymore :)
>
>Years ago, we had to manually change PAGE_OFFSET, and I remember some
>machines with PAGE_OFFSET 0xA0000000  (1.5 GB LOWMEM),=20
>or 0xB0000000 (1.25 GB), (PAE off)

I notice that 0xB0000000, which is now known as LOWMEM_3G_OPT,
is only available when PAE is off. Would you know the reason for
that decision? Are some values unsuitable for PAE?


