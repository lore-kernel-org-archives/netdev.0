From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Fri, 11 Apr 2014 16:08:27 -0300
Message-ID: <20140411190827.GC19199@arch.cereza>
References: <1397170682-19138-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140410.205128.1312451576920196881.davem@davemloft.net>
 <1397178150.16584.53.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140411054847.GE30855@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	tawfik@marvell.com, alior@marvell.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:48347 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754356AbaDKTI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 15:08:56 -0400
Content-Disposition: inline
In-Reply-To: <20140411054847.GE30855@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Apr 11, Willy Tarreau wrote:
> On Thu, Apr 10, 2014 at 06:02:30PM -0700, Eric Dumazet wrote:
> > On Thu, 2014-04-10 at 20:51 -0400, David Miller wrote:
> > > This is not really driver specific code.
> > >=20
> > > Please create an appropriate abstraction, and put this code in a
> > > common place so that any driver can do this.
> > >=20
> > > Thanks.
> >=20
> > Note a prior implementation existed in
> >=20
> > drivers/net/ethernet/tile/tilegx.c
> >=20
> > Note sure how it can be properly factorized, but worth trying .
>=20
> I also tried to find how to do this for mv643xx_eth a few years ago
>=20
[..]

Can you share *any* code about this attempt on mv643xx_eth? It would be
helpful to see other TSO cases, to have more examples in order to come
up with a proper abstraction.

--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
