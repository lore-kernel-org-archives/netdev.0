From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] slub: Make CONFIG_PAGE_ALLOC work with new fastpath
Date: Fri, 13 May 2011 23:26:42 +0200
Message-ID: <1305322002.3120.11.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
	 <1305022632.2614.18.camel@edumazet-laptop>
	 <4DC91137.4030109@cs.helsinki.fi>
	 <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
	 <alpine.DEB.2.00.1105101133440.2611@router.home>
	 <1305047682.2758.1.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101226460.2875@router.home>
	 <alpine.DEB.2.00.1105101242420.2875@router.home>
	 <1305050754.2758.12.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101323290.4023@router.home>
	 <1305055948.2437.13.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101435480.4023@router.home>
	 <1305057989.2437.18.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101531160.4023@router.home>
	 <1305060353.2437.26.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105101619430.4023@router.home>
	 <1305083543.2437.39.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105131614440.913@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36980 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757231Ab1EMV0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:26:47 -0400
Received: by wya21 with SMTP id 21so2204612wya.19
        for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:26:46 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105131614440.913@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 mai 2011 =C3=A0 16:15 -0500, Christoph Lameter a =C3=A9c=
rit :
> I ran this with hackbench under KVM with CONFIG_DEBUG_PAGEALLOC and I=
 saw
> no failures.
>=20
>=20
> Subject: slub: Make CONFIG_PAGE_ALLOC work with new fastpath
>=20
> Fastpath can do a speculative access to a page that CONFIG_PAGE_ALLOC=
 may have
> marked as invalid to retrieve the pointer to the next free object.
>=20
> Use probe_kernel_read in that case in order not to cause a page fault=
=2E
>=20
> Signed-off-by: Christoph Lameter <cl@linux.com>

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


