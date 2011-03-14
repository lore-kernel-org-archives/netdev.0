From: Yann Dupont <Yann.Dupont@univ-nantes.fr>
Subject: Re: kernel 2.6.37 : oops in cleanup_once
Date: Mon, 14 Mar 2011 11:44:51 +0100
Message-ID: <4D7DF1A3.6020501@univ-nantes.fr>
References: <4D491B8D.1000107@univ-nantes.fr>	 <1296643972.20445.9.camel@edumazet-laptop>	 <1296645887.20445.11.camel@edumazet-laptop>	 <4D495765.4090806@univ-nantes.fr>	 <1296658407.20445.19.camel@edumazet-laptop>	 <4D49726C.6020103@univ-nantes.fr> <1296659336.20445.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls2.univ-nantes.fr ([193.52.101.146]:37803 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721Ab1CNKwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 06:52:49 -0400
In-Reply-To: <1296659336.20445.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/02/2011 16:08, Eric Dumazet a =C3=A9crit :


> I suspect a mem corruption from another layer (not inetpeer)
>
> Unfortunately many kmem caches share the "64 bytes" cache.
>
> Could you please add "slub_nomerge" on your boot command ?
>
=2E..

>
>> -Is there a very severe impact on performance ?
>>
> not at all
>
Maybe there is an impact after all : since then, we don't have problems=
=20
anymore !

linkwood:~# uptime
  11:42:03 up 39 days, 17:08,  3 users,  load average: 0.01, 0.03, 0.05

So... could slub_nomerge hide or simply avoid the problem ?
Or are we just lucky this time ?


--=20
Yann Dupont - Service IRTS, DSI Universit=C3=A9 de Nantes
Tel : 02.53.48.49.20 - Mail/Jabber : Yann.Dupont@univ-nantes.fr

