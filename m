From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 09:06:05 +0100
Message-ID: <1292832365.6543.0.camel@edumazet-laptop>
References: <4D0DEDF9.7020102@itcare.pl>
	 <1292773433.18869.153.camel@edumazet-laptop> <4D0E2E52.3090802@itcare.pl>
	 <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
	 <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com>
	 <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com>
	 <4D0F0D73.2080807@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45984 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427Ab0LTJIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 04:08:24 -0500
Received: by wwa36 with SMTP id 36so2714250wwa.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 01:08:23 -0800 (PST)
In-Reply-To: <4D0F0D73.2080807@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 d=C3=A9cembre 2010 =C3=A0 09:01 +0100, Pawe=C5=82 Staszewsk=
i a =C3=A9crit :
> W dniu 2010-12-19 23:26, Jarek Poplawski pisze:
> > Jarek Poplawski wrote:
> >> Jarek Poplawski wrote:
> >>> Pawe=C5=82 Staszewski wrote:
> >>>> for sch_generic.h was ok.
> >>> Should be enough to try after reverting this sch_generic.h change=
 only.
> >> Hmm... Sorry, I meant the change inside skb_act_clone(). I'll send=
 a patch.
> > Here it is.
> >
> > Jarek P.
> >
> Yes reverting this patch solves the problem.

Thanks !

I tried to reproduce the crash without success. Might be related to 10G=
b
speed. (I only have 1Gb here right now)



