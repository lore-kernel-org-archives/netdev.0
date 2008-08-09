From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 05:09:53 +0200
Message-ID: <200808090509.53679.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808090354.03568.wolfgang.walter@stwm.de> <20080809021649.GA26784@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:57674 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752647AbYHIDJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 23:09:55 -0400
In-Reply-To: <20080809021649.GA26784@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 August 2008, Herbert Xu wrote:
> On Sat, Aug 09, 2008 at 03:54:03AM +0200, Wolfgang Walter wrote:
> > On Saturday 09 August 2008, Herbert Xu wrote:
> > >=20
> > > Someone please test this with tcrypt mode=3D200 with and without
> > > the patch.
> >=20
> > I'll do that. Where do I find tcrypt?
>=20
> It's part of the kernel.  Just make sure you've got CRYPTO_TEST
> enabled as a module.
>=20

Ok, that is easy :-). I'll make that test tomorrow. Bed time now :-).

I'll run that test on a unpatched 2.6.25 instead a unpatched 2.6.26 as =
latter=20
will crash. If you want I can use my 2.6.26 where I reverted the FPU st=
ate=20
changes (see one of my earlier mails for the patch), of course.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leiter EDV
Leopoldstra=DFe 15
80802 M=FCnchen
Tel: +49 89 38196-276
=46ax: +49 89 38196-144
wolfgang.walter@stwm.de
http://www.studentenwerk-muenchen.de/
