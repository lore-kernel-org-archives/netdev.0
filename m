From: Thomas Dreibholz <dreibh@iem.uni-due.de>
Subject: Re: [Bugme-new] [Bug 18592] New: Remote/local Denial of Service vulnerability in SCTP packet/chunk handling
Date: Sat, 18 Sep 2010 16:11:03 +0200
Message-ID: <201009181611.05665.dreibh@iem.uni-due.de>
References: <bug-18592-10286@https.bugzilla.kernel.org/> <20100915124340.5bf89d07.akpm@linux-foundation.org> <4C916615.4060400@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org,
	stable@kernel.org, David Miller <davem@davemloft.net>,
	Martin Becke <martin.becke@uni-due.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.uni-due.de ([132.252.185.19]:59651 "EHLO
	mailout.uni-due.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755290Ab0IROPm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 10:15:42 -0400
In-Reply-To: <4C916615.4060400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Donnerstag 16 September 2010, Vlad Yasevich wrote:
> On 09/15/2010 03:43 PM, Andrew Morton wrote:
> > Thanks, but please send patches via email, not via bugzilla.
> > Documentation/SubmittingPatches has some tips.  Suitable recipients=
 for
> > this patch are, from the MAINTAINERS file:
> >=20
> > M:      Vlad Yasevich <vladislav.yasevich@hp.com>
> > M:      Sridhar Samudrala <sri@us.ibm.com>
> > L:      linux-sctp@vger.kernel.org
> >=20
> > but please just send it as a reply-to-all to this email so that eve=
ryone
> > knows wht's happening.
> >=20
> > I'd suggest that you also add the line
> >=20
> > Cc: <stable@kernel.org>
> >=20
> > to the end of the changelog so that we don't forget to consider the
> > patch for backporting.
>=20
> Hi Andrew
>=20
> There is a much simpler solution to this problem that I posted to net=
dev
> today.

Dear all,

Vlad's patch solves the problem. I hope this patch can go into the mail=
ine=20
kernel soon, in order to get distribution kernels fixed as soon as poss=
ible. It=20
is relatively easy to trigger the denial of service problem, making all=
=20
systems providing SCTP-based services vulnerable to a remote DoS attack=
=2E

I have also been able to reproduce the problem with kernel 2.6.32, i.e.=
 at=20
least all kernels from 2.6.32 to 2.6.36 are affected.


Best regards
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
 Dr. Thomas Dreibholz

 University of Duisburg-Essen,                   Room ES210
 Inst. for Experimental Mathematics              Ellernstra=DFe 29
 Computer Networking Technology Group            D-45326 Essen/Germany
-----------------------------------------------------------------------
 E-Mail:     dreibh@iem.uni-due.de
 Homepage:   http://www.iem.uni-due.de/~dreibh
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
