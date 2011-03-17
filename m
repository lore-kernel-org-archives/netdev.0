From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTGMAC100 Gigabit Ethernet driver
Date: Thu, 17 Mar 2011 12:30:05 +0100
Message-ID: <1300361405.3133.175.camel@edumazet-laptop>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300355238-1619-1-git-send-email-ratbert.chuang@gmail.com>
	 <1300357457.3133.92.camel@edumazet-laptop>
	 <AANLkTino6LzGTZF4fNSkV9pbAfnmAc8wJjk0L8HfHDiJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39824 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760Ab1CQLaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 07:30:10 -0400
In-Reply-To: <AANLkTino6LzGTZF4fNSkV9pbAfnmAc8wJjk0L8HfHDiJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 mars 2011 =C3=A0 18:56 +0800, Po-Yu Chuang a =C3=A9crit :
> Hi Eric,
>=20
> On Thu, Mar 17, 2011 at 6:24 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le jeudi 17 mars 2011 =C3=A0 17:47 +0800, Po-Yu Chuang a =C3=A9crit=
 :
> >> From: Po-Yu Chuang <ratbert@faraday-tech.com>
> >>
> >> FTGMAC100 Ethernet Media Access Controller supports 10/100/1000 Mb=
ps
> >> and MII/GMII.  This driver has been working on some ARM/NDS32 SoC'=
s
> >> including Faraday A369 and Andes AG102.
> >>
> >> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> >> ---
> >
> > Did you tried GRO support ?
>=20
> No, I don't understand how to do that yet. Let me do some study first=
=2E
> I'd really appreciate it if you could provide me some pointers about =
GRO. :-)
> Is there any document about it?

Should be easy and might help performance too.

Take a look at commit :

2edae08e5b75269855fef3c74fe4292c066e7c33 (r8169: add gro support)


