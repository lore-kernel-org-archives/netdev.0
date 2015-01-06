From: Ani Sinha <ani@arista.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Tue, 6 Jan 2015 09:11:08 -0800
Message-ID: <CAOxq_8O-YME=m9NnCQ7hPWjr6jWqcqUkgeqM=ZY6VW+icNsO2g@mail.gmail.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
 <20150105.193614.1827024424476781168.davem@davemloft.net> <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
 <20150105.195128.794605376092864881.davem@davemloft.net> <CAOxq_8OysjN8OrvhM13t3YUuyh5O=KM_mptR=NHieq146mqZ8g@mail.gmail.com>
 <54ABD80F.7070602@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:52743 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022AbbAFRL3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 12:11:29 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so3780649iec.10
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 09:11:28 -0800 (PST)
In-Reply-To: <54ABD80F.7070602@draigBrady.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 4:41 AM, P=C3=A1draig Brady <P@draigbrady.com> w=
rote:
> On 06/01/15 00:56, Ani Sinha wrote:
>> On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> w=
rote:
>>> From: Ani Sinha <ani@arista.com>
>>> Date: Mon, 5 Jan 2015 16:43:30 -0800
>>>
>>>> On Mon, Jan 5, 2015 at 4:36 PM, David Miller <davem@davemloft.net>=
 wrote:
>>>>> From: Ani Sinha <ani@arista.com>
>>>>> Date: Mon, 5 Jan 2015 15:48:11 -0800
>>>>>
>>>>>> I am looking at the code and it looks like since the route cache=
 for
>>>>>> ipv4 was removed from the kernel, this sysctl parameter no longe=
r
>>>>>> serves the same purpose. It does not look like it is even used i=
n the
>>>>>> ipv4/route.c module. Is there an equivalent sysctl parameter lim=
iting
>>>>>> the number of route entries in the kernel? Or is there now no
>>>>>> mechanism to limit the number of route entries?
>>>>>
>>>>> There is nothing to limit, since the cache was removed.
>>>>
>>>> Shouldn't the documentation be updated to reflect that? Also what'=
s
>>>> the point of having a dummy variable that does nothing? Should we =
not
>>>> simply remove it?
>>>
>>> There is nothing to update, the behavior is completely transparent.
>>> Absolutely no cache entries exist, therefore the limit cannot be
>>> reached.
>>
>> I disagree. You are advertising a feature in an official documentati=
on
>> that simply does not exist for ipv4. This is very confusing. If I di=
d
>> not dig into the code, I wouldn't know that this particular knob is =
a
>> noop since the time the route cache was removed.
>
> You can't change APIs with impunity.
>
>>> The sysctl is kept so that scripts reading it don't suddenly stop
>>> working.  We can't just remove sysctl values.
>
> Perhaps /proc/sys/net/ipv4/route/max_size should always return 0 when=
 read,
> and discard written values?

Why can't se simply change the documentation to reflect the fact that
this sysctl is no longer in operation?
