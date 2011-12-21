From: Michal Simek <monstr@monstr.eu>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:54:25 +0100
Message-ID: <4EF1BAE1.7020409@monstr.eu>
References: <4EF1B0D9.2010007@monstr.eu>			 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		 <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>		 <4EF1B5BC.5020103@monstr.eu>	 <1324463838.2728.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4EF1B7E4.4010602@monstr.eu> <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33145 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab1LUKy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:54:27 -0500
Received: by eekc4 with SMTP id c4so7418219eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:54:26 -0800 (PST)
In-Reply-To: <1324464308.2728.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:41 +0100, Michal Simek a =
=C3=A9crit :
>=20
>> yes, page size is 4k.
>>
>> Here is the log for allocation - origin size for MTU 9000 is 0x2420(=
9248) and size after
>> overhead is 0x3f40(16192)
>>
>> kmalloc_node_track_caller size 00002420, SKB_WITH_OVERHEAD(ksize(dat=
a)) 00003f40
>> skb->head     c7870000
>> skb->data     c7870000
>> skb->tail     c7870000
>> skb->truesize 000040c0
>> skb->end      c7873f40
>>
>=20
> So basically truesize is bigger than previous kernel, and you hit a
> socket limit.  (RCVBUF ?)

Where is that limit setup?

Michal


--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
