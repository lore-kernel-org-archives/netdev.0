From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-2.6.24 0/3]: Attempt to fix lost_retrans
 brokeness
Date: Wed, 10 Oct 2007 02:48:09 -0700 (PDT)
Message-ID: <20071010.024809.10298656.davem@davemloft.net>
References: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
	<Pine.LNX.4.64.0710091600300.3767@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42891
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754055AbXJJJsG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 05:48:06 -0400
In-Reply-To: <Pine.LNX.4.64.0710091600300.3767@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 9 Oct 2007 16:03:29 +0300 (EEST)

> On Tue, 9 Oct 2007, Ilpo J=E4rvinen wrote:
>=20
> > Lost_retrans handling of sacktag was found to be flawed, two
> > problems that were found have an intertwined solution. Fastpath
> > problem has existed since hints got added and the other problem
> > has probably been there even longer than that. ...This change
> > may add non-trivial processing cost.
> >=20
> > Initial sketch, only compile tested. This will become more and
> > more useful, when sacktag starts to process less and less skbs,
> > which hopefully happens quite soon... :-) Sadly enough it will
> > probably then be consuming part of the benefits we're able to
> > achieve by less skb walking...
> >=20
> > First one is trivial, so Dave might want to apply it already.
>=20
> Hmm, forgot to add -n to git-format-patch. Since it's currently
> RFC, I won't bother to resubmit with numbers unless somebody
> really wants that. Here's the correct ordering, if it's not
> obvious from the patches alone:

I'm going to leave the 2nd patches and 3rd patches alone for
now so they can cook a little bit longer.

Thanks!
