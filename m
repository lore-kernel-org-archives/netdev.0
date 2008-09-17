From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 03/14] Phonet: build the net/phonet/ directory
Date: Wed, 17 Sep 2008 14:52:25 +1000
Message-ID: <20080917045224.GC7265@verge.net.au>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-3-git-send-email-remi.denis-courmont@nokia.com> <20080916160655.GG8702@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59682 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbYIQEw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 00:52:27 -0400
Content-Disposition: inline
In-Reply-To: <20080916160655.GG8702@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2008 at 01:06:55PM -0300, Arnaldo Carvalho de Melo wrot=
e:
> Em Tue, Sep 16, 2008 at 06:08:03PM +0300, R=E9mi Denis-Courmont escre=
veu:
> > Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> > ---
> >  net/Kconfig  |    1 +
> >  net/Makefile |    1 +
> >  2 files changed, 2 insertions(+), 0 deletions(-)
>=20
> Can't this be combined with 2/14?

Also, I think that the patches need to be re-ordered somehow.
As things stand, applying patches (1,) 2 & 3 and setting
CONFIG_PHONET=3Dy will try and build net/phonet/phonet.o,
but there is no source for that object at that point.

--=20
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

