From: Bill Fink <billfink@mindspring.com>
Subject: Re: tbf/htb qdisc limitations
Date: Thu, 14 Oct 2010 02:34:07 -0400
Message-ID: <20101014023407.80ccef7e.billfink@mindspring.com>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
	<4CB1A22B.9090701@gmail.com>
	<AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	<20101012101022.GA8578@ff.dom.local>
	<AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
	<20101012215932.GA1945@del.dom.local>
	<4CB4DE6E.7030802@hp.com>
	<20101013062649.GA6915@ff.dom.local>
	<20101013233653.1e363692.billfink@mindspring.com>
	<1287028881.2649.103.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:33112 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752400Ab0JNGeJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 02:34:09 -0400
In-Reply-To: <1287028881.2649.103.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Oct 2010, Eric Dumazet wrote:

> Le mercredi 13 octobre 2010 =E0 23:36 -0400, Bill Fink a =E9crit :
>=20
> > I was just trying to do an 8 Gbps rate limit on a 10-GigE path,
> > and couldn't get it to work with either htb or tbf.  Are you
> > saying this currently isn't possible?  Or are you saying to use
> > this hfsc mechanism, which there doesn't seem to be a man page
> > for?
>=20
> man pages ? Oh well...
>=20
> 8Gbps rate limit sounds very optimistic with a central lock and one
> queue...
>=20
> Maybe its possible to split this into 8 x 1Gbps, using 8 queues...
> or 16 x 500 Mbps

Not when I'm trying to rate limit a single flow.

				-Bill
