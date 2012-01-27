From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Fri, 27 Jan 2012 11:22:41 +0100
Message-ID: <1327659761.2220.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1327161325.git.richardcochran@gmail.com>
	 <1327638293.2729.43.camel@jtkirshe-mobl>
	 <20120127101119.GA6690@netboy.at.omicron.at>
	 <1327659327.2729.55.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46820 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760Ab2A0KWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 05:22:47 -0500
Received: by bkas6 with SMTP id s6so1238213bka.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 02:22:46 -0800 (PST)
In-Reply-To: <1327659327.2729.55.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 janvier 2012 =C3=A0 02:15 -0800, Jeff Kirsher a =C3=A9cr=
it :
> On Fri, 2012-01-27 at 11:11 +0100, Richard Cochran wrote:
> > On Thu, Jan 26, 2012 at 08:24:53PM -0800, Jeff Kirsher wrote:
> > > Richard-
> > >=20
> > > Did you compile test?  Why I ask is our validation team is gettin=
g the
> > > following errors when trying to compile in PTP support:
> >=20
> > I did compile and also tested the driver.
> >=20
> > What .config are you using? What kernel version?
> >=20
> > Thanks,
> > Richard
>=20
> I will have Aaron post his .config's that he tried.  I know that he
> tried multiple configs with no success.  As far as kernel version, he
> was using the latest net-next tree from David Miller.

This might coming from

commit 36a1211970193ce215de50ed1e4e1272bc814df1
Author: Paul Gortmaker <paul.gortmaker@windriver.com>
Date:   Tue Jan 24 11:33:19 2012 +0000

    netprio_cgroup.h: dont include module.h from other includes
   =20
    A considerable effort was invested in wiping out module.h
    from being present in all the other standard includes.  This
    one leaked back in, but once again isn't strictly necessary,
    so remove it.
   =20
