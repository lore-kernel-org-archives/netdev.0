From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GSO and IPv4 forwarding
Date: Tue, 26 Oct 2010 22:43:28 +0200
Message-ID: <1288125808.2652.46.camel@edumazet-laptop>
References: <AANLkTikxNYGFAmyZDit9fTp=-M8wfYp3Ew8rejsjHWHb@mail.gmail.com>
	 <1288124114.2652.25.camel@edumazet-laptop>
	 <AANLkTik+s4CHgPuY6uhe-0aD=WJs=UHhoEdok4AyTdYJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63798 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757441Ab0JZUnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 16:43:37 -0400
Received: by wwe15 with SMTP id 15so5173163wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 13:43:36 -0700 (PDT)
In-Reply-To: <AANLkTik+s4CHgPuY6uhe-0aD=WJs=UHhoEdok4AyTdYJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 octobre 2010 =C3=A0 22:26 +0200, Kevin Wilson a =C3=A9crit =
:
> Hi,
> Thanks a lot for your quick answer, I appreciate it (and did not
> expect it to be so quick!)
>=20
> Can someone please explain in 2-3 short sentences Why GRO can be
> forwarded and LRO cannot be forwarded ?

Well, GRO is a pure software thing, completely handled in linux stack,
not driver specific. Its design included forwarding ability, LRO did
not.

http://lwn.net/Articles/311357/



