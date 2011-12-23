From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Fri, 23 Dec 2011 06:35:55 +0100
Message-ID: <1324618555.10854.4.camel@edumazet-laptop>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
	 <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
	 <1324616007.2674.8.camel@edumazet-laptop>
	 <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
	 <1324617390.2674.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:63707 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203Ab1LWFgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 00:36:00 -0500
Received: by wibhm6 with SMTP id hm6so2942191wib.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 21:35:59 -0800 (PST)
In-Reply-To: <1324617390.2674.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 06:16 +0100, Eric Dumazet a =C3=
=A9crit :

> 32 bit truncation _is_ a bound checking problem too.
>=20
> Really, mixing INT_MAX / ULONG_MAX is ugly, this should had ring a be=
ll
> when writing such hard to read code.
>=20
> You cannot claim to give more range to 64bit platform, yet not spotti=
ng
> the 32bit truncation issue.
>=20
> When fixing a bug, its always a good thing to look things around, and
> try to check the whole function.
>=20
>=20

By the way, the theorical limit on number of flows on 64bit platform is
2^32  (rxhash being an u32)

Not sure spending 32GB per table would be wise for typical machines :)
