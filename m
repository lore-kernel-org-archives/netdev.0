From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Mon, 5 Feb 2007 16:12:05 +0100
Message-ID: <200702051612.06492.arnd@arndb.de>
References: <20070116185524.GA5681@dmt> <20070203224349.GA18418@dmt> <20070205140147.GA17286@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:55603 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617AbXBEPMh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 10:12:37 -0500
In-Reply-To: <20070205140147.GA17286@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 15:01, John W. Linville wrote:
>=20
> > I disagree, entry/exit points have been shown to be useful in pract=
ice
> > to identify firmware problems on field.
>=20
> I'm not too fond of the ENTER/LEAVE stuff either. =A0But, I do sympat=
hize
> that they _can_ be useful in certain circumstances/workflows/whatever=
=2E
>=20
> Is there an official "party line" on this documented somewhere
> (i.e. CodingStyle or elsewhere)? =A0A quick search doesn't reveal one
> to me.

I don't think there is a formal rule. My personal opinion is that
you should trace events that come from the hardware of from the user,
if you trace at all, but never trace function call sequences that
can be simply identified by knowing the source code.

	Arnd <><
