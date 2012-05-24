From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH IPROUTE2] tc-codel: Add manpage
Date: Thu, 24 May 2012 11:19:59 -0700
Message-ID: <CAGK4HS8_O94rQZmvxeNjeYtbT3_a2C1FsZ9O=b9_n0vV2putdA@mail.gmail.com>
References: <1337834034-27803-1-git-send-email-subramanian.vijay@gmail.com>
	<1337835239.3361.3954.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:43674 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757797Ab2EXSUA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 14:20:00 -0400
Received: by ghrr11 with SMTP id r11so48570ghr.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 11:19:59 -0700 (PDT)
In-Reply-To: <1337835239.3361.3954.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +.SS target
>> +Default and recommended value is 5ms.
>
> Although I can tell I prefer lower values on hosts.
>
> On 10Gbe links, I used 500us target
>
>> +.SS interval
>> +give endpoints sufficient time to react. =A0Default value is 100ms.
>
> Same here. In a datacenter, you might reduce this to 20ms or so...
>

Thanks for the insight. The paper does claim that codel can be run
with the same setting, regardless of link rate.
I guess reality is different.

Thanks,
Vijay
