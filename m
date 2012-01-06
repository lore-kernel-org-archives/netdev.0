From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 06 Jan 2012 18:07:59 +0100
Message-ID: <1325869679.2911.27.camel@edumazet-laptop>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	 <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325867504.2911.23.camel@edumazet-laptop>
	 <CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kathleen Nichols <nichols@pollere.com>,
	Jim Gettys <jg@freedesktop.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45814 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758820Ab2AFRII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 12:08:08 -0500
Received: by wgbdr13 with SMTP id dr13so1950572wgb.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 09:08:07 -0800 (PST)
In-Reply-To: <CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 janvier 2012 =C3=A0 17:56 +0100, Dave Taht a =C3=A9crit =
:
> On Fri, Jan 6, 2012 at 5:31 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Adds an optional Random Early Detection on each SFQ flow queue.
>=20
> netperf -t TCP_RR is useful
> -t TCP_MAERTS will be interesting.
> simultaneous ping?
>=20

I dont know what you expect from pings, since they are already coming i=
n
new flows (unless a ping flood is in effect), so RED doesnt fire for
these packets.

Same for TCP_RR : Since at most one packet is in flight per flow, RED
cannot fire.

So there is no differences for them.
