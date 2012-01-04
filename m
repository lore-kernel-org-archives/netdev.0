From: "Li, Zhen-Hua" <lizhenhua.dev@gmail.com>
Subject: Re: A pure virtual nic
Date: Wed, 4 Jan 2012 10:07:08 +0800
Message-ID: <CAEk7JKa-H=7oHjU-A1z8aNUZxd3TkJpBmwwrp4zWmZ_i2SQ+Tg@mail.gmail.com>
References: <CAEk7JKbQgjiL90oGyWy6jkwY7eudUUqLP7GvdjfMcotTN8YhwQ@mail.gmail.com>
	<CAHXqBFKstJCQ4rif6S7mNuQUzFjJ1wfRKAksFePJyBoTw0YTfg@mail.gmail.com>
	<CAEk7JKY6xtBm4DraqRMYEnmZZhsOZoZG-MSgrq+W4n2eCCz1Sg@mail.gmail.com>
	<4EFDDC55.80406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44224 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549Ab2ADCHP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 21:07:15 -0500
Received: by iaeh11 with SMTP id h11so31752080iae.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 18:07:14 -0800 (PST)
In-Reply-To: <4EFDDC55.80406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a program sends out a packet, at start_xmit function. it will
unpack it and packet again with HTTP proxy headers, then give it to
the actual physical ethernet adapter.
When it receives a packet, unpack it and remove the http proxy
headers, and then put it back to the queue in kernel.


2011/12/30 Ben Greear <greearb@candelatech.com>:
> On 12/29/2011 05:51 PM, Li, Zhen-Hua wrote:
>>
>> I plan to add some protocols to it. For example, HTTP Proxy packet
>> analysis. So user-space programs can use an NIC in common way in a
>> proxy needed environment.
>
>
> When a program transmits a packet on your virtual NIC, where does the
> packet go? =A0When it receives a packet, where did the packet come fr=
om?
>
> Thanks,
> Ben
>
>>
>>
>>
>> 2011/12/29 Micha=B3 Miros=B3aw<mirqus@gmail.com>:
>>>
>>> 2011/12/29 Zhen-Hua Li<lizhenhua.dev@gmail.com>:
>>>>
>>>> I have opened a project in SourceForge, it provides a pure virtual
>>>> ethernet adapter. =A0If you are interested to join it, please mail=
 me.
>>>
>>>
>>> Is veth or tap (both in vanilla kernel) not enough for you? What ar=
e
>>> the differences?
>>>
>>> Best Regards,
>>> Micha=B3 Miros=B3aw
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =A0http://www.candelatech.com
