From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Very low latency TCP for clusters
Date: Tue, 20 Jul 2010 07:26:10 +0200
Message-ID: <1279603570.2458.66.camel@edumazet-laptop>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>
	 <1279561319.2553.153.camel@edumazet-laptop>
	 <AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>
	 <1279576980.2458.56.camel@edumazet-laptop>
	 <AANLkTillCVWMHHBImGEeRYy2MJYqtGIvSPvacLKJnpP2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38604 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458Ab0GTF0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 01:26:15 -0400
Received: by wwj40 with SMTP id 40so321966wwj.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 22:26:14 -0700 (PDT)
In-Reply-To: <AANLkTillCVWMHHBImGEeRYy2MJYqtGIvSPvacLKJnpP2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 juillet 2010 =C3=A0 16:37 -0700, Tom Herbert a =C3=A9crit :

> That's pretty pokey ;-) I see numbers around 25 usecs between to
> machines, this is with TCP_NBRR.  With TCP_RR it's more like 35 usecs=
,
> so eliminating the scheduler is already a big reduction.  That leaves
> 18 usecs in device time, interrupt processing, network, and cache
> misses; 7 usecs in TCP processing, user space.  While 5 usecs is an
> aggressive goal, I am not ready to concede that there's an
> architectural limit in either NICs, TCP, or sockets that can't be
> overcome.

Last time I tried TCP_NBRR, it was not working (not even compiled in), =
I
guess I should submit a bug report to Rick ;)



