From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 14:54:38 -0700 (PDT)
Message-ID: <20070424.145438.78383473.davem@davemloft.net>
References: <20070424183827.adb60ae0.dada1@cosmosbay.com>
	<20070424100420.2860db68@dxpl.pdx.osdl.net>
	<462E50F6.50700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	bunk@stusta.de, netdev@vger.kernel.org, tglx@linutronix.de
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33358
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754645AbXDXVyb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 17:54:31 -0400
In-Reply-To: <462E50F6.50700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 24 Apr 2007 20:48:22 +0200

> Stephen Hemminger a =E9crit :
> > =20
> > +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> > +
> >  #else
>=20
> Oh dear... how many bogus patches are going to be posted today ?

Stephen please submit a working patch, thanks :-)
