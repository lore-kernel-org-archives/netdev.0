From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: Re: [PATCH iproute2] pedit action: add mask for changing bits.
Date: Mon, 27 Feb 2012 17:15:30 +0300
Message-ID: <CAEzD07KenHteg0S8-OfAwqTNTSQdvPOJsA-m_+8CW-8c_HCgnw@mail.gmail.com>
References: <CAEzD07+0EA12igqAcwbM8VGKLR9Hp0GjJ7t_Jve=JXOrEKvu9w@mail.gmail.com>
	<1330351135.2384.1039.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44239 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753600Ab2B0OPb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 09:15:31 -0500
Received: by wejx9 with SMTP id x9so294789wej.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 06:15:30 -0800 (PST)
In-Reply-To: <1330351135.2384.1039.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Jamal.

2012/2/27 jamal <hadi@cyberus.ca>:
>
> Looks like a reasonable feature to have - but it has to continue work=
ing
> as before for things that dont need the mask.
>
>>
>> diff --git a/tc/m_pedit.c b/tc/m_pedit.c
>> index 7499846..f081eff 100644
>> --- a/tc/m_pedit.c
>> +++ b/tc/m_pedit.c
>
>>
>> =C2=A0 =C2=A0 =C2=A0 tkey->val =3D htonl(tkey->val & retain);
>> - =C2=A0 =C2=A0 tkey->mask =3D htonl(tkey->mask | ~retain);
>> + =C2=A0 =C2=A0 tkey->mask =3D htonl(~tkey->mask | ~retain);
>
> A change like the above worries me that this may work for your use ca=
se
> but will break other things that used to work. I'd like to run some
> tests but dont have the cycles for the next few days. Alternatively, =
I
> could explain some tests to you and you could validate and fix whatev=
er
> breaks.
> Let me know what is best for you.
>

Can You explain tests to me? I'll check behavior with my changes and fi=
x breaks


--=20
Anton.
