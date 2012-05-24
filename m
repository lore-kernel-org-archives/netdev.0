From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH IPROUTE2] tc-codel: Add manpage
Date: Thu, 24 May 2012 19:28:09 +0100
Message-ID: <CAA93jw5m=CdzNhKixWBRNcGf0zuQEXY7T9n0b6Yi=i_0OBvXfg@mail.gmail.com>
References: <1337834034-27803-1-git-send-email-subramanian.vijay@gmail.com>
	<1337835239.3361.3954.camel@edumazet-glaptop>
	<CAGK4HS8_O94rQZmvxeNjeYtbT3_a2C1FsZ9O=b9_n0vV2putdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:57845 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933458Ab2EXS2K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 14:28:10 -0400
Received: by wgbdr13 with SMTP id dr13so70569wgb.1
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 11:28:09 -0700 (PDT)
In-Reply-To: <CAGK4HS8_O94rQZmvxeNjeYtbT3_a2C1FsZ9O=b9_n0vV2putdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

well, it would be nice if codel could sense it was on 10gigE or
greater, and self adjust.

On Thu, May 24, 2012 at 7:19 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
>>> +.SS target
>>> +Default and recommended value is 5ms.
>>
>> Although I can tell I prefer lower values on hosts.
>>
>> On 10Gbe links, I used 500us target
>>
>>> +.SS interval
>>> +give endpoints sufficient time to react. =A0Default value is 100ms=
=2E
>>
>> Same here. In a datacenter, you might reduce this to 20ms or so...
>>
>
> Thanks for the insight. The paper does claim that codel can be run
> with the same setting, regardless of link rate.
> I guess reality is different.
>
> Thanks,
> Vijay



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
