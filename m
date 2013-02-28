From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Thu, 28 Feb 2013 18:26:57 +0800
Message-ID: <512F30F1.208@asianux.com>
References: <512F1534.9020404@asianux.com> <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:30585 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865Ab3B1K1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 05:27:19 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 17:36, David Laight =E5=86=
=99=E9=81=93:
>> > diff --git a/net/rds/stats.c b/net/rds/stats.c
>> > index 7be790d..b9ac1df 100644
>> > --- a/net/rds/stats.c
>> > +++ b/net/rds/stats.c
>> > @@ -86,7 +86,7 @@ void rds_stats_info_copy(struct rds_info_iterato=
r *iter,
>> >=20
>> >  	for (i =3D 0; i < nr; i++) {
>> >  		BUG_ON(strlen(names[i]) >=3D sizeof(ctr.name));
>> > -		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
>> > +		strlcpy(ctr.name, names[i], sizeof(ctr.name));
>> >  		ctr.value =3D values[i];
>> >=20
> If the target buffer ends up being copied to userspace that
> might lead to random kernel memory being leaked.

  excuse me, I do not quite understand what your meaning.

  I guess what you said is:
    if crt.name is not ended by '\0', it will cause issue.
    the issue is:
      "If the target buffer ends up being copied to userspace that
       might lead to random kernel memory being leaked."

  is it correct ?
    if it is correct, need I add them as patch comments, too ?
    else (incorrect), please give more descriptions, thanks.


  :-)

--=20
Chen Gang

Asianux Corporation
