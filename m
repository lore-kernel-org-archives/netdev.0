From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix slowness in read /proc/net/tcp
Date: Mon, 07 Jun 2010 12:32:11 +0200
Message-ID: <1275906731.2545.47.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1006062020180.24064@pokey.mtv.corp.google.com>
	 <1275895167.2545.8.camel@edumazet-laptop>
	 <87eigjgrcw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Yakov Lerner <iler.ml@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52292 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab0FGKcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 06:32:16 -0400
Received: by fxm8 with SMTP id 8so1928395fxm.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 03:32:14 -0700 (PDT)
In-Reply-To: <87eigjgrcw.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 10:49 +0200, Andi Kleen a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> >
> > BTW, another problem of /proc/net/tcp is the buffer size used by ne=
tstat
> > utility : 1024 bytes instead of PAGE_SIZE, making O(N^2) behavior e=
ven
> > more palpable.
>=20
> That would be easily fixable in netstat.
>=20
> But I'm not sure net-tools is still maintained as a separate package,
> afaik the standard procedure is to submit a patch to a big distributi=
on
> and the others take it from there.

Well, it seems this is fixed in latest netstat, sorry for the noise (I
still have machines with RHEL 4)



