From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 18:23:19 +0200
Message-ID: <1309882999.2271.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	 <1309846875.2720.43.camel@edumazet-laptop> <4E12B5A6.2020802@inliniac.net>
	 <1309849214.2720.45.camel@edumazet-laptop>
	 <D3F292ADF945FB49B35E96C94C2061B91257D61B@nsmail.netscout.com>
	 <1309882577.2271.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E133A09.8030907@inliniac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Victor Julien <victor@inliniac.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47982 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216Ab1GEQXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:23:35 -0400
Received: by wwe5 with SMTP id 5so6106550wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:23:34 -0700 (PDT)
In-Reply-To: <4E133A09.8030907@inliniac.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 18:21 +0200, Victor Julien a =C3=A9crit=
 :
> On 07/05/2011 06:16 PM, Eric Dumazet wrote:
> > Remember, goal is that _all_ packets of a given flow end in same qu=
eue.
> >=20
>=20
> What about a hashing scheme based on just the ip addresses? Would mak=
e
> rxhash useless for this purpose, but would be a lot simpler overall m=
aybe...
>=20

What about loads where a single IP address is used ?

I wonder what's the problem, since David added a defrag unit ;)



