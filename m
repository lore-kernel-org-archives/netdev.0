From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 18:36:31 +0200
Message-ID: <1283877391.2313.62.camel@edumazet-laptop>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>
	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>
	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51261 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757599Ab0IGQgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 12:36:37 -0400
Received: by fxm16 with SMTP id 16so93524fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 09:36:36 -0700 (PDT)
In-Reply-To: <4C865C21.5010803@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 17:37 +0200, Krzysztof Ol=C4=99dzki a=
 =C3=A9crit :

> So far I have found that:
>=20
> 2.6.31.7/2.6.31.12: OK
> 2.6.32.21: OK
> 2.6.33-rc1: bad
> 2.6.33-rc5: bad
> 2.6.33.7: bad
> 2.6.34.4/2.6.34.6: bad
>=20
> It looks like the bug must have been introduced in 2.6.33-rc1. There =
are=20
> 8904 commits between 2.6.32 and 2.6.33-rc1, so with ~15 more reboots =
I=20
> should be able to point the problematic commit. I hope. ;)
>=20
>=20

Hmm, I have a pretty good idea of what the problem is, and will post a
fix soon ;)

Thanks !



