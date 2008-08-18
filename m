From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 18 Aug 2008 10:05:14 +0800
Message-ID: <1219025114.25933.6.camel@ymzhang>
References: <48A086B6.2000901@linux-foundation.org>
	 <20080811.141501.01468546.davem@davemloft.net>
	 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:11477 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750943AbYHRCGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 22:06:07 -0400
In-Reply-To: <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-08-12 at 11:13 +0300, Ilpo J=E4rvinen wrote:=20
> On Mon, 11 Aug 2008, David Miller wrote:
>=20
> > From: Christoph Lameter <cl@linux-foundation.org>
> > Date: Mon, 11 Aug 2008 13:36:38 -0500
> >=20
> > > It seems that the network stack becomes slower over time? Here is=
 a list of
> > > tbench results with various kernel versions:
> > >=20
> > > 2.6.22		3207.77 mb/sec
> > > 2.6.24		3185.66
> > > 2.6.25		2848.83
> > > 2.6.26		2706.09
> > > 2.6.27(rc2)	2571.03
> > >=20
> > > And linux-next is:
> > >=20
> > > 2.6.28(l-next)	2568.74
> > >=20
> > > It shows that there is still have work to be done on linux-next. =
Too close to
> > > upstream in performance.
> > >=20
> > > Note the KT event between 2.6.24 and 2.6.25. Why is that?
> >=20
> > Isn't that when some major scheduler changes went in?  I'm not blam=
ing
> > the scheduler, but rather I'm making the point that there are other
> > subsystems in the kernel that the networking interacts with that
> > influences performance at such a low level.
>=20
> ...IIRC, somebody in the past did even bisect his (probably netperf)=20
> 2.6.24-25 regression to some scheduler change (obviously it might or =
might=20
> not be related to this case of yours)...
I did find much regression with netperf TCP-RR-1/UDP-RR-1/UDP-RR-512. I=
 start
1 serve and 1 client while binding them to a different logical processo=
r in
different physical cpu.

Comparing with 2.6.22, the regression of TCP-RR-1 on 16-core tigerton i=
s:
2.6.23		6%
2.6.24		6%
2.6.25		9.7%
2.6.26		14.5%
2.6.27-rc1	22%

Other regressions on other machines are similar.

yanmin


