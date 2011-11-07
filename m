From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding Routing table in Linux kernel
Date: Mon, 07 Nov 2011 07:21:29 +0100
Message-ID: <1320646889.6506.46.camel@edumazet-laptop>
References: <CADAe=+J-yjh-GujhVY58qKirGNANQ6fUnPdzvoQzQSxMDv7VPw@mail.gmail.com>
	 <1320601372.6506.11.camel@edumazet-laptop>
	 <CADAe=+KTYAGT4N9R2eTHstbBP89PJPD57jYNp6diGocnoYkaFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61359 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681Ab1KGGVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 01:21:33 -0500
Received: by wyh15 with SMTP id 15so4131828wyh.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 22:21:32 -0800 (PST)
In-Reply-To: <CADAe=+KTYAGT4N9R2eTHstbBP89PJPD57jYNp6diGocnoYkaFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 novembre 2011 =C3=A0 09:52 +0530, Ajith Adapa a =C3=A9crit =
:

> I will check it with the latest kernel. Actually I am just checking i=
n
> a 2.6.18 kernel.
>=20

2.6.18 is very old in this respect. Lot of things changed in recent
kernels in route cache handling. We no longer have long pauses because
of garbage collector runs.
