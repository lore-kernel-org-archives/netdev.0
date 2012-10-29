From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vxlan nits
Date: Mon, 29 Oct 2012 07:20:56 -0700
Message-ID: <20121029072056.5faa6db4@nehalam.linuxnetplumber.net>
References: <201210191148.q9JBkm0v018443@lab1.dls>
	<20121019132815.547a5bb8@nehalam.linuxnetplumber.net>
	<m3objm45n7.fsf@neo.luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David L Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60046 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751Ab2J2OVr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 10:21:47 -0400
In-Reply-To: <m3objm45n7.fsf@neo.luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 Oct 2012 23:02:20 +0100
Vincent Bernat <bernat@luffy.cx> wrote:

>  =E2=9D=A6 19 octobre 2012 22:28 CEST, Stephen Hemminger <shemminger@=
vyatta.com>=C2=A0:
>=20
> > The plan is to add IPV6 support, in which case group address could
> > be IPV6.
>=20
> Hi Stephen!
>=20
> Is it something that you plan to add soon?

The only real question is whether to have one driver do dual stack with
one forwarding table, or separate drivers (like GRE). I prefer the form=
er.

Since the RFC does not include IPv6 yet, there is no rush and the final
standard may address some of the corner case issues like fragmentation.
