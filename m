From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netem: fix classful handling
Date: Thu, 29 Dec 2011 19:10:36 +0100
Message-ID: <1325182236.2607.50.camel@edumazet-laptop>
References: <1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	 <1324664907.2915.5.camel@edumazet-laptop>
	 <20111223110749.7a690685@nehalam.linuxnetplumber.net>
	 <1324668083.2915.15.camel@edumazet-laptop>
	 <1325132760.2607.15.camel@edumazet-laptop>
	 <20111228221731.4d4954a9@s6510.linuxnetplumber.net>
	 <1325149922.2607.33.camel@edumazet-laptop> <20111229165249.GB2948@hell>
	 <1325178950.2607.46.camel@edumazet-laptop> <20111229174323.GC2948@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56376 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab1L2SKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 13:10:44 -0500
Received: by wgbdr13 with SMTP id dr13so23506979wgb.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 10:10:43 -0800 (PST)
In-Reply-To: <20111229174323.GC2948@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 d=C3=A9cembre 2011 =C3=A0 18:43 +0100, Hagen Paul Pfeifer a=
 =C3=A9crit :
> * Eric Dumazet | 2011-12-29 18:15:50 [+0100]:
>=20
> >> In other words netem jitter and a qdisc !tfifo will not work. Corr=
ect? The
> >> rate extension also peak the last packet to get the reference time=
 (assuming a
> >> strict ordering):
> >>=20
> >
> >Yep, current situation is borked. It assumes we _use_ tfifo, for del=
ay
> >jitters but also for rate extension.
>=20
> Mhh, should we signal this to the user via 'tc -s qdisc show'? Or sho=
uld we
> assume that a user who set netem rate|jitter AND a qdisc !tfifo knows=
 what he
> does - because we assume he is a experienced user? At least somewhere=
 in the
> manpage a comment should point to this characteristic.

I dont quite understand the question. The patch I posted is supposed to
fix the problem. What do you want to tell to the user ?

netem module is probably only used by experimented users, on very recen=
t
kernels anyway.
