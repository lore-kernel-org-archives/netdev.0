From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Tue, 05 Mar 2013 11:32:05 +0800
Message-ID: <51356735.4020405@asianux.com>
References: <512F1534.9020404@asianux.com>   <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>   <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>  <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>  <51355936.3060307@asianux.com> <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:60017 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759081Ab3CEDc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 22:32:28 -0500
In-Reply-To: <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B403=E6=9C=8805=E6=97=A5 11:16, Ben Hutchings =E5=86=
=99=E9=81=93:
> I think it is wrong, and the code should be changed to do either:
>=20
> 1. Zero-initialise the whole of the name, then use strlcpy().
> 2. Keep using strncpy(), and also set the last byte of name to 0.
>=20

  I think what I have done is just like your choice "2."
  for me, I think they are equal:

-		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
+		strlcpy(ctr.name, names[i], sizeof(ctr.name));


		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
+ 		ctr.name[sizeof(ctr.name) - 1] =3D '\0';



>> > BTW:
>> >   excuse me, maybe my reply will be late during this week.
>> >   the reason:
>> >     my father had a serious heart disease, and is in hospital.
>> >     during these days, most of my time has to be in hospital.
>> >       (God Bless, and thank Jesus Christ, my father is safe, now).
>> >     within my company (Asianux), I also have something to do.
> Best wishes to you both.

  thank you.

  :-)

--=20
Chen Gang

Asianux Corporation
