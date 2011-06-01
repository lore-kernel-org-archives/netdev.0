From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: Section conflict compile failures in net
Date: Wed, 1 Jun 2011 03:27:40 +0200
Message-ID: <20110601012739.GA25705@rere.qmqm.pl>
References: <1306445993.4048.58.camel@mulgrave.site>
 <20110531.154531.493226762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55418 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933005Ab1FAB1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 21:27:41 -0400
Content-Disposition: inline
In-Reply-To: <20110531.154531.493226762.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2011 at 03:45:31PM -0700, David Miller wrote:
> From: James Bottomley <James.Bottomley@HansenPartnership.com>
> Date: Thu, 26 May 2011 16:39:53 -0500
>=20
> BTW, linux-netdev doesn't exist, it's just plain netdev.
>=20
> > Simply reverting=20
> >=20
> > commit e5cb966c0838e4da43a3b0751bdcac7fe719f7b4
> > Author: Micha<C5><82> Miros<C5><82>aw <mirq-linux@rere.qmqm.pl>
> > Date:   Mon Apr 18 13:31:20 2011 +0000
> >=20
> >     net: fix section mismatches
> >    =20
> > Fixes the problem.
> >=20
> > If I look at the first problem in hp100.c, the addition of
> > __devinitconst to the device tables is fine, but there's no
> > corresponding sectional tag on their use, so when compiled as a mod=
ule,
> > things like hp100_eisa_driver is now in the main data section but r=
efers
> > to something in the init data section ... I assume all the others a=
re
> > the same type of problem.
> Yeah I think the device ID table __devinitconst bits have to be
> reverted.

__devinitconst ID tables do work for PCI drivers. What's different for =
EISA,
and why is it working in x86 allyesconfig build but not in hppa?

Best Regards,
Micha=B3 Miros=B3aw
