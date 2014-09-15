From: Sebastian Moeller <moeller0@gmx.de>
Subject: Re: how to figure out which device a given IFB is connected to
Date: Mon, 15 Sep 2014 23:24:54 +0200
Message-ID: <719B90A7-0D8A-4CBB-A0EB-2BDCAA36FEEC@gmx.de>
References: <CBDE840F-96BA-4839-9774-86F72E99E964@gmx.de> <CAHA+R7NxSY8fbAMLgekAxeN4n5U_NTKUczFRz9WUcY-xSHZTxw@mail.gmail.com> <E5E81534-C300-42C1-B2DF-84C006A117AD@gmx.de> <20140915135508.5b346e22@urahara>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:51379 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605AbaIOVY6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:24:58 -0400
In-Reply-To: <20140915135508.5b346e22@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Mr. Hemminger,


On Sep 15, 2014, at 22:55 , Stephen Hemminger <stephen@networkplumber.o=
rg> wrote:

> On Mon, 15 Sep 2014 21:06:31 +0200
> Sebastian Moeller <moeller0@gmx.de> wrote:
>=20
>> Hi Mr. Wang,
>>=20
>> Thank you for your help.
>>=20
>> On Sep 15, 2014, at 18:08 , Cong Wang <cwang@twopensource.com> wrote=
:
>>=20
>>> On Mon, Sep 15, 2014 at 7:37 AM, Sebastian Moeller <moeller0@gmx.de=
> wrote:
>>>> I am looking for a way of doing the reverse,i.e.  figuring out for=
 a given IFB if it is =93connected=94 to a real interface and, if yes, =
which interface. Basically, I want to recycle unused IFBs, but want to =
make sure that they really are unused=85
>>>>=20
>>>=20
>>> There is no way to figure that out.
>>=20
>> 	That is rather unfortunate, so my only recourse is to get a list of=
 all interfaces and query each whether it is attached to an fib and pru=
ne a list of IFBs so that only the unused ones remain (which is far fro=
m elegant ;) ).
>=20
> It can be a many to one mapping.
> There are cases where you want multiple incoming devices to all be Qo=
S'd together.

	Good to know, thanks for this information.

Best Regards
	Sebastian Moeller
