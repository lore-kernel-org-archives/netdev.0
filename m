From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Mon, 10 Dec 2012 09:39:08 +0800
Message-ID: <50C53D3C.7090804@asianux.com>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil> <50BED40D.9080100@asianux.com> <50BEDE4E.8010408@asianux.com> <50BEE2BE.2030704@asianux.com> <20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil> <50BFF19E.1040405@asianux.com> <20121206090855.5f166746@thirdoffive.cmf.nrl.navy.mil> <50C1415C.2060104@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:36702 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab2LJBiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 20:38:15 -0500
In-Reply-To: <50C1415C.2060104@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Chas Williams:

  Excuse me:
    I am a reporter (not a reviewer), and not suitable to review anothe=
r's patch.

  so:
    I suggest you to send your patch (as your willing) to the reviewers=
, directly.
    and need not cc to me (I am not a reviewer).

  thanks.

gchen.


=D3=DA 2012=C4=EA12=D4=C207=C8=D5 09:07, Chen Gang =D0=B4=B5=C0:
> =D3=DA 2012=C4=EA12=D4=C206=C8=D5 22:08, chas williams - CONTRACTOR =D0=
=B4=B5=C0:
>> On Thu, 06 Dec 2012 09:15:10 +0800
>> Chen Gang <gang.chen@asianux.com> wrote:
>>
>>> =D3=DA 2012=C4=EA12=D4=C205=C8=D5 22:55, chas williams - CONTRACTOR=
 =D0=B4=B5=C0:
>>
>>>> did you mean '\0' instead of '\n'?  scnprintf() considers the trai=
ling
>>>> '\0' when formatting.
>>>
>>>   no, originally, the end is "\n\0".
>>>
>>>   I prefer we still compatible "\n" when the contents are very larg=
e.
>>>   if count already =3D=3D (PAGE_SIZE - 1), we have no chance to app=
end "\n" to the end.
>>>
>>> -		pos +=3D sprintf(pos, "\n");
>>> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");
>>
>> i would make the code a bit messy to do this for not much gain.  aga=
in,
>> it isnt likely you would run into this in a normal situation.
>=20
>   surely.
>=20
>   thanks.
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
