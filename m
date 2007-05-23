From: Ben Greear <greearb@candelatech.com>
Subject: Re: IFF_PROMISC again
Date: Tue, 22 May 2007 17:08:18 -0700
Message-ID: <465385F2.7080309@candelatech.com>
References: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWFydMOtbiBGZXJyYXJp?= <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:52972 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756741AbXEWAIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 20:08:25 -0400
In-Reply-To: <1178044568.7116.14.camel@abraxas.dyn-o-saur.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mart=C3=ADn Ferrari wrote:
> Hi, for the nth time I send this email, hoping that majordomo won't e=
at
> it again.
>=20
>=20
> I know this has been extensibly discussed circa 2001, but I found tha=
t
> there's still problems: in debian (at least) neither ifconfig nor ip
> can tell that the interface is in promiscuous mode.
>=20
> I know about the deprecation of IFF_PROMISC, but I couldn't find out
> which is the current way of knowing the real state of the interface. =
I
> want to fix ifconfig, so this is not an issue of
> PACKET_(ADD|REMOVE)_MEMBERSHIP, I need to query the real device state=
=2E

I have the same problem.  I think you can tell by looking at bit 0x100
in /sys/class/net/[ethX]/flags

Not exactly fun to use, but it seems to work.

Anyone know the reasoning for masking out the PROMISC flag
in dev_get_flags() ?

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

