From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] Could we avoid touching dst->refcount in some cases ?
Date: Mon, 24 Nov 2008 12:27:09 +0100
Message-ID: <20081124112709.GX6703@one.firstfloor.org>
References: <492A6C94.7030308@cosmosbay.com> <87y6z9h33h.fsf@basil.nowhere.org> <492A7E85.3060502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39478 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbYKXLQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 06:16:57 -0500
Content-Disposition: inline
In-Reply-To: <492A7E85.3060502@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 11:14:29AM +0100, Eric Dumazet wrote:
> Andi Kleen a =E9crit :
> >Eric Dumazet <dada1@cosmosbay.com> writes:
> >
> >>tbench has hard time incrementing decrementing the route cache refc=
ount
> >>shared by all communications on localhost.
> >
> >iirc there was a patch some time ago to use per CPU loopback devices=
 to=20
> >avoid this, but it was considered too much a benchmark hack.
> >As core counts increase it might stop being that though.
>=20
> Well, you probably mention Stephen patch to avoid dirtying other cont=
ended
> cache lines (one napi structure per cpu)

No that patch wasn't from Stephen. iirc it was from someone at SGI.

-Andi

--=20
ak@linux.intel.com
