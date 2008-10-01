From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Wed, 01 Oct 2008 03:07:53 -0700 (PDT)
Message-ID: <20081001.030753.246288202.davem@davemloft.net>
References: <20080925094905.GA19180@gondor.apana.org.au>
	<48DB801E.90500@iki.fi>
	<48DB85B4.10104@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hadi@cyberus.ca
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752420AbYJAKIE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 06:08:04 -0400
In-Reply-To: <48DB85B4.10104@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 25 Sep 2008 15:36:04 +0300

> Timo Ter=E4s wrote:
> > Herbert Xu wrote:
> >> Thanks! I've got some other work to do so feel free to post this
> >> tomorrow.
> >=20
> > It was simpler than I thought (and I thought I would be more busy
> > with other things). Anyway, here goes. This is a single patch that
> > modifies both xfrm_state and xfrm_policy dumping. This was to get
> > af_key patch nicer (the final skb patching/sending is common code).
>=20
> One more thing I noticed. If the af_key socket is closed while
> dumping is ongoing the current code can leak stuff. We should call
> the .done. And also in the new patch, release the stored skb.
>=20
> The right place to do that would be pfkey_release, I assume?

I reread this thread, and the most recent patch seems good
and even tested :-)  But it seems that you want to make some
more tweaks, right?

Please post explicitly the patch you want me to apply to
net-next-2.6 once you reach that point, thanks!
