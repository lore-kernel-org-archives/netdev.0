From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 02 Dec 2011 18:12:12 +0100
Message-ID: <1322845932.2762.38.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs>
	 <1322836191.2762.3.camel@edumazet-laptop>
	 <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
	 <1322838687.2762.18.camel@edumazet-laptop>
	 <6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
	 <1322844451.2762.36.camel@edumazet-laptop>
	 <CAFdo_mWtxexXXCpFZsQKAJ96ZXEnDRiBsb4zFO8oR0hc6gXPMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tom Herbert <therbert@google.com>
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49888 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756969Ab1LBRMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 12:12:17 -0500
Received: by bkas6 with SMTP id s6so4089602bka.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 09:12:16 -0800 (PST)
In-Reply-To: <CAFdo_mWtxexXXCpFZsQKAJ96ZXEnDRiBsb4zFO8oR0hc6gXPMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 18:00 +0100, Igor Maravi=C4=87=
 a =C3=A9crit :
> >
> > They are initted at device setup.
> >
>=20
> What about when device is reseted?
>=20

What happens to queued skbs ? Are they LOST ?

Think about it.


> >
> > Oh well, no, dont do that. BQL must be lightweight.
> >
>=20
> Forcedeth driver utilizes spin_locks. :)

No added spin_locks in BQL patch.

Reread what I said : "BQL must be lightweight"

Not : "No lock should be used"

OK ?
