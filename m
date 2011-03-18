From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 19:58:06 +0000
Message-ID: <1300478286.2589.29.camel@bwh-desktop>
References: <1300457877.26693.53.camel@localhost>
	 <1300458784.2888.138.camel@edumazet-laptop>
	 <20110318081524.42d18bd2@nehalam>
	 <20110318.125221.212667543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com, jdb@comx.dk,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40917 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760Ab1CRT6z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:58:55 -0400
In-Reply-To: <20110318.125221.212667543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 12:52 -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 18 Mar 2011 08:15:24 -0700
>=20
> > On Fri, 18 Mar 2011 15:33:04 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> >> Le vendredi 18 mars 2011 =C3=A0 14:17 +0000, Ben Hutchings a =C3=A9=
crit :
> >>=20
> >> > WARN is correct as this is a driver bug.  But I agree that the
> >> > device/driver ID should be included.
> >>=20
> >> stack trace gives absolutely no useful indication here.
> >>=20
> >> Bug is in driver, yet we dump information on core network stack ?
> >>=20
> >> pr_err() is an error indication, not a warning by the way ;)
> >=20
> > The advantage of WARN is that it doesn't get ignored and shows
> > up in kernel oops. But agreed it should print out as much device
> > info as possible to finger the broken device driver.
>=20
> Infrastructure is not static, therefore we could add a WARN_ON_NETDEV=
()
> or similar.  An in fact such things would probably be very useful.

You mean like netdev_WARN()? :-)

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

