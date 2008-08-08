From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 01:10:42 +0200
Message-ID: <200808090110.42391.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808082109.47284.wolfgang.walter@stwm.de> <20080808193252.GD607@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:53031 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbYHHXKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 19:10:44 -0400
In-Reply-To: <20080808193252.GD607@linux-os.sc.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 August 2008, Suresh Siddha wrote:
> On Fri, Aug 08, 2008 at 12:09:46PM -0700, Wolfgang Walter wrote:
> > I don't know though why kernel_fpu_begin exactly fixes the problem:
>=20
> because it prevents taking a DNA fault inside the kernel (resulting
> in TS_USEDFPU not set).
>=20
> >=20
> > Maybe preemption must be disabled when padlocks RNG, ACE, Hash-engi=
ne etc.=20
is
> > used. Maybe just some barrier is needed which preempt_disable provi=
des.
>=20
> problem can happen even when preemption is disabled.
>=20
> > What should I do now?
>=20
> I will post your fix(including the other usages) with the appropriate=
=20
changelog
> shortly.
>=20

=46ine.

By the way, if padlock is used from userspace, could this be aproblem, =
too? I=20
mean not via the kernel crypto layer but directly. I think these extens=
ions=20
are not restricted to a privileged user.

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
