From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Fri, 18 Mar 2011 08:15:24 -0700
Message-ID: <20110318081524.42d18bd2@nehalam>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	<1300453519.2888.118.camel@edumazet-laptop>
	<1300457877.26693.53.camel@localhost>
	<1300458784.2888.138.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44543 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486Ab1CRPPa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 11:15:30 -0400
In-Reply-To: <1300458784.2888.138.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Mar 2011 15:33:04 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 18 mars 2011 =C3=A0 14:17 +0000, Ben Hutchings a =C3=A9cr=
it :
>=20
> > WARN is correct as this is a driver bug.  But I agree that the
> > device/driver ID should be included.
>=20
> stack trace gives absolutely no useful indication here.
>=20
> Bug is in driver, yet we dump information on core network stack ?
>=20
> pr_err() is an error indication, not a warning by the way ;)

The advantage of WARN is that it doesn't get ignored and shows
up in kernel oops. But agreed it should print out as much device
info as possible to finger the broken device driver.
