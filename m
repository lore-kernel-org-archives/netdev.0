From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] Probable bug in icsk_probes_out handling ?
Date: Wed, 23 Jul 2008 23:11:54 -0700 (PDT)
Message-ID: <20080723.231154.246071098.davem@davemloft.net>
References: <48873397.5040409@cosmosbay.com>
	<20080723.163444.165532483.davem@davemloft.net>
	<48881178.3080901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753107AbYGXGLy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 02:11:54 -0400
In-Reply-To: <48881178.3080901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 24 Jul 2008 07:22:00 +0200

> David Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Wed, 23 Jul 2008 15:35:19 +0200
> >=20
> >> Apparently, we can in some situations reset TCP connections in a c=
ouple of seconds when some frames are lost.
> >=20
> > I think it is some optimization that went in between 2.2.x and 2.4.=
x
> > which took things a little bit too far.
> >=20
> > Please try this patch:
>=20
> Yes, this patch solves the problem.=20
> I tried a similar patch yesterday but was not sure about its validity=
=2E
> Thanks a lot David.

Thanks for testing.
