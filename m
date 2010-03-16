From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] route: Fix caught BUG_ON during
 rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 14:18:16 -0400
Message-ID: <20100316181816.GC13529@hmsreliant.think-freely.org>
References: <201003161407.51925.vgusev@openvz.org>
 <20100316143437.GA8225@hmsreliant.think-freely.org>
 <201003161827.08595.vgusev@openvz.org>
 <20100316173543.GA13529@hmsreliant.think-freely.org>
 <1268762922.2932.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vitaliy Gusev <vgusev@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44090 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757121Ab0CPSSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 14:18:21 -0400
Content-Disposition: inline
In-Reply-To: <1268762922.2932.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 16, 2010 at 07:08:42PM +0100, Eric Dumazet wrote:
> Le mardi 16 mars 2010 =C3=A0 13:35 -0400, Neil Horman a =C3=A9crit :
> > >=20
> > Dave, Eric, Herbert, what are your opinions on this?  Is the statis=
tical analysis code
> > mature enough at this point to warrant the removal of the rebuild t=
imer, or
> > should we still keep it as a fallback mechanism?
> > Neil
>=20
> I believe most heavy duty users dont use newest kernels yet.
>=20
> (I had to make some changes last month because Pawe=C5=82 Staszewski =
had
> problems to get a working route cache)
>=20
> We should wait a bit (one year or two) before removing this timer.
>=20
> Thanks
>=20
>=20
>=20
Ok, I just figured it was time to pose the question, since we'd fixed s=
everal
bugs in this area over the last year.  Certainly doesn't hurt to keep t=
he
rebuild timer around a bit longer.  I re-iterate my ack to Vitaliy's pa=
tch then.

Regards
Neil


