From: Wolfgang Walter <linux@stwm.de>
Subject: Re: GRO: forwading ISATAP packets is very slow with kernel 4.1
Date: Wed, 15 Jul 2015 14:25:59 +0200
Message-ID: <2477915.Hv2mXUtnDZ@stwm.de>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de> <8145949.lUzHGl5xdY@h2o.as.studentenwerk.mhn.de> <20150715095019.GA881@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:42165 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751014AbbGOM0B convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 08:26:01 -0400
In-Reply-To: <20150715095019.GA881@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 15. Juli 2015, 17:50:20 schrieb Herbert Xu:
> On Wed, Jul 15, 2015 at 02:34:41AM +0200, Wolfgang Walter wrote:
> > I wonder if the router may treat all ipv6-tcp connections of a host=
 as a
> > single flow as all those ipv6-packets are embedded in ipv4-packets =
with
> > the
> > ipv4-address of the host and the ipv4-address of the isatap-gateway=
 and
> > next- header is 41. It may only looks at those?
>=20
> I think GRO is actually working fine.  Can you show me the output
> of ethtool -k eth1? If hardware TSO is enabled can you try disabling
> it to see if it helps?
>=20
> Thanks,

Yes. Switching TSO off and leaving GRO on works, too.

Thanks,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
