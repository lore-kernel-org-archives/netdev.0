From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Mon, 11 Oct 2010 18:07:17 +0200
Message-ID: <1286813237.2737.37.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	 <20101008145256.GB10393@redhat.com>
	 <1286550247.2959.444.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1010111102390.11247@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45003 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab0JKQHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 12:07:23 -0400
Received: by wye20 with SMTP id 20so580951wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 09:07:22 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1010111102390.11247@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 11:03 -0500, Christoph Lameter a =C3=A9=
crit :
> On Fri, 8 Oct 2010, Eric Dumazet wrote:
>=20
> > 8 in the <pagesperslab> column just says that : order-3 pages, even=
 for
> > small allocations.
>=20
> Those allocations will fallback to smaller allocs if the page allocat=
or
> has trouble satisfying those requests.
>=20

Interesting, do you have an idea when this feature was added ?

Thanks


