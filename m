From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix a timewait refcnt race
Date: Fri, 04 Dec 2009 07:29:05 +0100
Message-ID: <4B18AC31.3040800@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>	 <4B152F97.1090409@gmail.com>	 <20091202.005937.177088443.davem@davemloft.net>	 <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com>	 <20091202113213.GA18453@ioremap.net>	 <99d458640912021118y42a6fe4bm7b742a2046ad7a3b@mail.gmail.com>	 <99d458640912021843y21ad07a4j724003328da07e9@mail.gmail.com>	 <4B17979D.4040301@gmail.com> <99d458640912031920n7e4e0f39o4c04e9c51b46efd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
To: kapil dakhane <kdakhane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35351 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbZLDG3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 01:29:06 -0500
In-Reply-To: <99d458640912031920n7e4e0f39o4c04e9c51b46efd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kapil dakhane a =E9crit :
>=20
> I applied your changes are suggested above. It appears that the patch
> successfully resolves the race condition it addressed. I managed to
> push the system to 1.9 gbps, previously I could not push it beyond 1.=
6
> gbps. Unfortunately, there appear to be more race conditions, as the
> fault happened again when I attempted to push it to 2.3 gbps. This
> time I did not get any error message in /var/log/messages, although
> they appear on the console the same way as before.
>=20

Thanks for testing Kapil

I am not sure of exact set of changes you have in your kernel.

David, could you push your net-next-2.6 tree with pending changes so th=
at
I can work on bind() side (interaction with timewait) and be sure Kapil
can work on latest net-next-2.6 ?

Thanks
