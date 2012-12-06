From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Thu, 06 Dec 2012 17:05:06 +0800
Message-ID: <50C05FC2.70004@asianux.com>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil> <50BED40D.9080100@asianux.com> <50BEDE4E.8010408@asianux.com> <50BEE2BE.2030704@asianux.com> <20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil> <50BFF19E.1040405@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:7205 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030197Ab2LFJEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 04:04:13 -0500
In-Reply-To: <50BFF19E.1040405@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chas Williams:

  all of my original reply are my idea (or suggestions), not for issues=
=2E

  if you do not need them, please help to send patch.

  I have tried to check it. at least, I did not find issues (and I also
also learned from it)

  hope the patch can pass reviewers checking !

  Good Luck !

  :-)

gchen.

=D3=DA 2012=C4=EA12=D4=C206=C8=D5 09:15, Chen Gang =D0=B4=B5=C0:
> =D3=DA 2012=C4=EA12=D4=C205=C8=D5 22:55, chas williams - CONTRACTOR =D0=
=B4=B5=C0:
>> On Wed, 05 Dec 2012 13:59:26 +0800
>>
>> it doesn't seem like optimizing for this corner case is a huge
>> concern.  the list cannot be infinitely long.
>>
>=20
>   ok.
>=20
>=20
>>>>>
>>>>> By the way:
>>>>>   will it be better that always let "\n" at the end ?
>>>>>   (if count =3D=3D PAGE_SIZE in a loop, we can not let "\n" at th=
e end).
>>>>
>>>>    oh, sorry ! count will never >=3D PAGE_SIZE.
>>>>
>>>>    I think let "PAGE_SIZE - 2" instead of "PAGE_SIZE" in the loop,=
 so we
>>>> can make the room for the end of "\n".
>>>>
>>>>
>>>>
>>>    sorry, "PAGE_SIZE - 1" is enough, not need "PAGE_SIZE - 2".
>>
>> did you mean '\0' instead of '\n'?  scnprintf() considers the traili=
ng
>> '\0' when formatting.
>=20
>   no, originally, the end is "\n\0".
>=20
>   I prefer we still compatible "\n" when the contents are very large.
>   if count already =3D=3D (PAGE_SIZE - 1), we have no chance to appen=
d "\n" to the end.
>=20
> -		pos +=3D sprintf(pos, "\n");
> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");
>=20
>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>=20
>=20


--=20
Chen Gang

Asianux Corporation
