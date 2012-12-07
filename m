From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Fri, 07 Dec 2012 09:07:40 +0800
Message-ID: <50C1415C.2060104@asianux.com>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil> <50BED40D.9080100@asianux.com> <50BEDE4E.8010408@asianux.com> <50BEE2BE.2030704@asianux.com> <20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil> <50BFF19E.1040405@asianux.com> <20121206090855.5f166746@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:11182 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424095Ab2LGBGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 20:06:48 -0500
In-Reply-To: <20121206090855.5f166746@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA 2012=C4=EA12=D4=C206=C8=D5 22:08, chas williams - CONTRACTOR =D0=
=B4=B5=C0:
> On Thu, 06 Dec 2012 09:15:10 +0800
> Chen Gang <gang.chen@asianux.com> wrote:
>=20
>> =D3=DA 2012=C4=EA12=D4=C205=C8=D5 22:55, chas williams - CONTRACTOR =
=D0=B4=B5=C0:
>=20
>>> did you mean '\0' instead of '\n'?  scnprintf() considers the trail=
ing
>>> '\0' when formatting.
>>
>>   no, originally, the end is "\n\0".
>>
>>   I prefer we still compatible "\n" when the contents are very large=
=2E
>>   if count already =3D=3D (PAGE_SIZE - 1), we have no chance to appe=
nd "\n" to the end.
>>
>> -		pos +=3D sprintf(pos, "\n");
>> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");
>=20
> i would make the code a bit messy to do this for not much gain.  agai=
n,
> it isnt likely you would run into this in a normal situation.

  surely.

  thanks.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


--=20
Chen Gang

Asianux Corporation
