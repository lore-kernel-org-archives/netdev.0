From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH linux-firmware] linux-firmware: bnx2: Update mips
 firmware to fix iSCSI problems
Date: Wed, 21 Dec 2011 18:13:50 +0000
Message-ID: <20111221181350.GG20752@decadent.org.uk>
References: <1324268012-27719-1-git-send-email-mchan@broadcom.com>
 <1324457726.2728.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <0E685F8B314BFB42AE2422915B7BDCC30752F5@IRVEXCHMB07.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	"'dwmw2@infradead.org'" <dwmw2@infradead.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52335 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751730Ab1LUSN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 13:13:58 -0500
Content-Disposition: inline
In-Reply-To: <0E685F8B314BFB42AE2422915B7BDCC30752F5@IRVEXCHMB07.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2011 at 04:49:10PM +0000, Michael Chan wrote:
> Eric Dumazet wrote:
>=20
> > Le dimanche 18 d=E9cembre 2011 =E0 20:13 -0800, Michael Chan a =E9c=
rit :
> > > New firmware fixes iSCSI problems with some LeftHand targets that
> > don't
> > > set TTT=3D0xffffffff for Data-In according to spec.  Firmware gen=
erates
> > > exception warnings for this condition and becomes very slow.  Thi=
s is
> > > fixed by suppressing these warnings when using default error mask=
=2E
> > >
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > ---
> > >  WHENCE                      |    2 ++
> > >  bnx2/bnx2-mips-06-6.2.3.fw  |  Bin 0 -> 92824 bytes
> > >  bnx2/bnx2-mips-09-6.2.1b.fw |  Bin 0 -> 103904 bytes
> > >  3 files changed, 2 insertions(+), 0 deletions(-)
> > >  create mode 100644 bnx2/bnx2-mips-06-6.2.3.fw
> > >  create mode 100644 bnx2/bnx2-mips-09-6.2.1b.fw
> >=20
> > IMHO, this should be applied _before_ the drivers/net patch.
> >=20
>=20
> Ben,
>=20
> If David Woodhouse is not available, can you help us apply this firmw=
are
> patch?

Yes, but please don't expect instant response.

Ben.

--=20
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert =
Camus
