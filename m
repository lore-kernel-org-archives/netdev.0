From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 00:49:00 -0800 (PST)
Message-ID: <20080117.004900.58497170.davem@davemloft.net>
References: <478F05E7.6070503@iki.fi>
	<20080116.235923.208347316.davem@davemloft.net>
	<478F0DA5.2060401@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59437
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752540AbYAQItB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 03:49:01 -0500
In-Reply-To: <478F0DA5.2060401@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Thu, 17 Jan 2008 10:11:17 +0200

> I thought my patch would qualify as "life support" bug fix.
> Currently racoon fails to work if there are too many SPDs or SAs
> because the kernel cannot handle the dump request properly. And this
> is what my patch fixes for pfkey. It adds no new features or
> functionality; just makes the dumping work with large databases.

Racoon should use netlink for reasons far and beyond the
problem you are trying to address.

The dumping behavior of AF_KEY is just horrific, as one of
several examples.

> Then there's also the xfrm dumping changes which change the
> algorithm from O(n^2) to O(n) with some memory overhead, but
> that is a different story. Any comments on that?

I have no general objections to those changes although I am
backlogged and thus have not studied them in detail.  Jamal
is having what appears to be a healthy dialogue with you about
the details so I'm not concerned much :)
