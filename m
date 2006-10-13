From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct inet_peer), cleanup,
 change in peer_check_expire()
Date: Fri, 13 Oct 2006 06:24:52 +0200
Message-ID: <452F1514.90207@cosmosbay.com>
References: <452EA214.7080905@cosmosbay.com>
 <20061012.151529.95506153.davem@davemloft.net>
 <452F0E7B.3010701@cosmosbay.com> <20061012.211843.15264081.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:13454 "EHLO smtp.Neuf.fr")
	by vger.kernel.org with ESMTP id S1751624AbWJMEYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 00:24:48 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604005mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J72000T549ARRW0@sp604005mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 13 Oct 2006 06:24:47 +0200 (CEST)
In-reply-to: <20061012.211843.15264081.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Fri, 13 Oct 2006 05:56:43 +0200
>=20
>> 2^31 is 2147483648
>>
>> Thats a *lot* of timer ticks, an inet_peer entry should not stay in=20
>> unused_list for more than 10 minutes.
>=20
> My bad, I thought the time was compared to the creation time
> not the time at which it was added to the unused list.
>=20
> I like your patch and I'll apply it.
>=20
> Thanks Eric.

Thank you David

(Re-reading my previous mail, I forgot to say that on ia32, unsigned lo=
ng is=20
already 32 bits, so if a 32bits timestamp is OK (for delta computing) f=
or such=20
platforms, it must be  OK for other platforms as well)

Eric

