From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [NET]: uninline skb_put, de-bloats a lot
Date: Thu, 27 Mar 2008 15:04:56 -0700 (PDT)
Message-ID: <20080327.150456.39560267.davem@davemloft.net>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1206645050.4849.77.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	acme@redhat.com, mpm@selenic.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758968AbYC0WE4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 18:04:56 -0400
In-Reply-To: <1206645050.4849.77.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Thu, 27 Mar 2008 12:10:50 -0700

> On Thu, 2008-03-27 at 14:38 +0200, Ilpo J=E4rvinen wrote:
> > Allyesconfig (v2.6.24-mm1):
>=20
> I think this change is only good in severely memory
> limited uses.  This will very likely negatively impact
> high speed networking.  It's a speed/size trade off.

I severely doubt this, the bulk of the overhead of
skb_put() is the atomic operation, not whether the
instructions get executed inline or not.

Please run some tests before making claims like this.
I might give you some slack in this area if you've
been doing networking performance tuning for 10+ years
but you haven't.
