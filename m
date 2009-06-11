From: David Miller <davem@davemloft.net>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 03:09:22 -0700 (PDT)
Message-ID: <20090611.030922.91415233.davem@davemloft.net>
References: <4A30BECA.8030205@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kuznet@ms2.inr.ac.ru
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40130
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756983AbZFKKJT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 06:09:19 -0400
In-Reply-To: <4A30BECA.8030205@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 11 Jun 2009 11:22:34 +0300

> I'm not entirely sure about this, but shouldn't we do something like
> the below to make ip_gre allocation enough headroom for paths where
> e.g. xfrm transformations take place (as a speed optimization)?

This should be handled by the code one level up that allocates
the SKB.

And as routes get stacked, the MTUs and headroom values get adjusted
up to the root.

At least that's how it's supposed to work :-)

Otherwise we'd need a similar hack in ipip.c too.
