From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CBQ broken in 2.6
Date: Thu, 28 Jan 2010 22:27:42 +0100
Message-ID: <1264714062.3380.20.camel@edumazet-laptop>
References: <20100128125317.GA8931@ff.dom.local>
	 <1264685696.4038.14.camel@mare-infinitum.sigsegv.cx>
	 <20100128184519.GA3109@del.dom.local>
	 <1264708135.22027.13.camel@magrat.sigsegv.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:34895 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab0A1V1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 16:27:50 -0500
Received: by bwz27 with SMTP id 27so972921bwz.21
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 13:27:44 -0800 (PST)
In-Reply-To: <1264708135.22027.13.camel@magrat.sigsegv.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 janvier 2010 =C3=A0 19:48 +0000, Anton Ivanov a =C3=A9crit =
:

> Well, I know CBQ reasonably well from a "network engineer" perspectiv=
e.
> I used to run it production in an ISP 1998 and after that in an SMB
> 2002-2007. I have also been running it in lab and on my home network =
for
> 10+ years. Mostly on BSD though. There was even a point where I
> maintained a fork of the patches before they went into the main tree.
> The sole reason I ditched BSD was that they plugged it into the pf
> framework and it became too big of a hassle to port/maintain the
> configs.
>=20
> I know what I am doing and HTB is not what I want. It is a good algo =
for
> expressing classic commerical relationships (CIR/PIR). It is worse th=
an
> CBQ for "sharing" where all of the apps that share are your own and t=
he
> scheduler/estimator is good.
>=20
> Thanks for all the help.=20

I am using CBQ myself with recent kernels and never found it
'borrowing', could you post a copy of your rules, or better, a subset o=
f
them desmonstrating the problem ?



