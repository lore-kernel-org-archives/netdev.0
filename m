From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 06 Jan 2012 20:33:35 +0100
Message-ID: <1325878415.2911.42.camel@edumazet-laptop>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	 <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325867504.2911.23.camel@edumazet-laptop>
	 <CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com>
	 <1325869679.2911.27.camel@edumazet-laptop> <4F073DD5.6000006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kathleen Nichols <nichols@pollere.com>,
	Jim Gettys <jg@freedesktop.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55952 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755425Ab2AFTdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 14:33:39 -0500
Received: by wgbdr13 with SMTP id dr13so2070003wgb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 11:33:38 -0800 (PST)
In-Reply-To: <4F073DD5.6000006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 janvier 2012 =C3=A0 10:30 -0800, Rick Jones a =C3=A9crit=
 :

> netperf nitpick :)  While I doubt that Dave Taht is running it that w=
ay,=20
> one can have multiple requests in flight on a single _RR test via the=
=20
> test-specific -b <additionaltrans> option.  That option is enabled by=
=20
> default (--enable-burst on the configure) in 2.5.0 and later.

Ah Rick, I dont think we can tune IP_TOS with netperf -t UDP_{STREAM|
RR} ?

I ask because it could be a good thing to set ECT(0) on datagrams to
check our ECN capabilities and get in the final report from receiver a
count/percentage of CE frames.
