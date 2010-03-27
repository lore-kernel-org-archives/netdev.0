From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 14:25:31 +0200
Message-ID: <4BADF93B.3070609@iki.fi>
References: <4BADDDB7.4010005@iki.fi> <20100327114059.GA3432@electric-eye.fr.zoreil.com> <4BADF01E.9090906@iki.fi> <20100327120358.GA5114@electric-eye.fr.zoreil.com> <4BADF738.2060600@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois_Romieu?= <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:51710 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014Ab0C0MZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 08:25:34 -0400
Received: by ewy20 with SMTP id 20so241753ewy.1
        for <netdev@vger.kernel.org>; Sat, 27 Mar 2010 05:25:33 -0700 (PDT)
In-Reply-To: <4BADF738.2060600@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Fran=E7ois Romieu wrote:
>> Timo Ter=E4s <timo.teras@iki.fi> :
>> [...]
>>> I don't think this would do anything. The high part is recorded=20
>>> correctly always.
>>> It's the 'low' part that gets discarded. I can do similar test if=20
>>> writing it
>>> more times will help. Will post results soon.
>>
>> You may check whether writing MAC4 before MAC0 makes a difference
>> or not as well.
>=20
> It seems that adding single printk between writing MAC0 and MAC4 fixe=
s it.
> I guess it needs a bit of delay between the writes or something.

Oh, and writing MAC4 first seems to fix it too.

- Timo

