From: David Miller <davem@davemloft.net>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 12:52:21 -0700 (PDT)
Message-ID: <20110318.125221.212667543.davem@davemloft.net>
References: <1300457877.26693.53.camel@localhost>
	<1300458784.2888.138.camel@edumazet-laptop>
	<20110318081524.42d18bd2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com, jdb@comx.dk,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	alexander.h.duyck@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932112Ab1CRTvn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 15:51:43 -0400
In-Reply-To: <20110318081524.42d18bd2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 18 Mar 2011 08:15:24 -0700

> On Fri, 18 Mar 2011 15:33:04 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le vendredi 18 mars 2011 =E0 14:17 +0000, Ben Hutchings a =E9crit :
>>=20
>> > WARN is correct as this is a driver bug.  But I agree that the
>> > device/driver ID should be included.
>>=20
>> stack trace gives absolutely no useful indication here.
>>=20
>> Bug is in driver, yet we dump information on core network stack ?
>>=20
>> pr_err() is an error indication, not a warning by the way ;)
>=20
> The advantage of WARN is that it doesn't get ignored and shows
> up in kernel oops. But agreed it should print out as much device
> info as possible to finger the broken device driver.

Infrastructure is not static, therefore we could add a WARN_ON_NETDEV()
or similar.  An in fact such things would probably be very useful.
