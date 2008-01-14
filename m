From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in
	2.6.24-rc6,	comparing with 2.6.22
Date: Mon, 14 Jan 2008 17:38:36 +0800
Message-ID: <1200303516.3151.30.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
	 <1200043854.3265.24.camel@ymzhang>
	 <Pine.LNX.4.64.0801141036400.31652@kivilampi-30.cs.helsinki.fi>
	 <Pine.LNX.4.64.0801141118450.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:19409 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753999AbYANJlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 04:41:03 -0500
In-Reply-To: <Pine.LNX.4.64.0801141118450.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-01-14 at 11:21 +0200, Ilpo J=E4rvinen wrote:
> On Mon, 14 Jan 2008, Ilpo J=E4rvinen wrote:
>=20
> > On Fri, 11 Jan 2008, Zhang, Yanmin wrote:
> >=20
> > > On Wed, 2008-01-09 at 17:35 +0800, Zhang, Yanmin wrote:=20
> > > >=20
> > > > As a matter of fact, 2.6.23 has about 6% regression and 2.6.24-=
rc's
> > > > regression is between 16%~11%.
> > > >=20
> > > > I tried to use bisect to locate the bad patch between 2.6.22 an=
d 2.6.23-rc1,
> > > > but the bisected kernel wasn't stable and went crazy.
> >=20
> > TCP work between that is very much non-existing.
>=20
> I _really_ meant 2.6.22 - 2.6.23-rc1, not 2.6.24-rc1 in case you had =
a=20
> typo
I did bisect 2.6.22 - 2.6.23-rc1. I also tested it on the latest 2.6.24=
-rc.

>  there which is not that uncommon while typing kernel versions... :-)
Thanks. I will retry bisect and bind the server/client to the same logi=
cal processor, where
I hope the result is stable this time when bisecting.

Manual testing showed there is still same or more regression if I bind =
the
processes on the same cpu.


Thanks a lot!

-yanmin


