From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding Routing table in Linux kernel
Date: Sun, 06 Nov 2011 18:42:52 +0100
Message-ID: <1320601372.6506.11.camel@edumazet-laptop>
References: <CADAe=+J-yjh-GujhVY58qKirGNANQ6fUnPdzvoQzQSxMDv7VPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:65403 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab1KFRm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 12:42:57 -0500
Received: by wwi36 with SMTP id 36so5699991wwi.1
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 09:42:56 -0800 (PST)
In-Reply-To: <CADAe=+J-yjh-GujhVY58qKirGNANQ6fUnPdzvoQzQSxMDv7VPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 06 novembre 2011 =C3=A0 12:43 +0530, Ajith Adapa a =C3=A9cr=
it :
> Hi,
>=20
> I have few doubts regarding the routing table in linux kernel.
>=20
> 1. Why does the linux kernel use hashing table for storing routing
> entries when there is patricia trie or radix tree which is more faste=
r
> than Hash table ?
>=20

I think you are mistaken. Routes are stored in a trie in recent kernels=
=2E

And route cache is scheduled to be removed at some point.

In normal situation, one hash lookup is the faster way to find a random
item, its a single memory cache line cost.


> 2. Is there any way we can test the performance of an routing
> algorithm before deploying in a real time scenario to check its
> performance ? I would like to test one of my implementations to check
> if there are any performance gains or not ?

Sorry there is no general answer. It all depends on your needs.
