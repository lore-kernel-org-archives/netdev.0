From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: MPLS for Linux kernel
Date: Tue, 22 Nov 2011 16:51:55 +0100
Message-ID: <CAFdo_mUH=21_+xuLqE6tytHmD-QwXb9XXfTzixYFqUcbcLAfWQ@mail.gmail.com>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com>
	<4ECA67C6.2080802@dti2.net>
	<20111121.132914.1611617296397809001.davem@davemloft.net>
	<4ECAA41C.9040007@dti2.net>
	<CAFdo_mXzqC_v5OkC6P012gFT_OmRO_yDTA0w96VhV-Lp3Hp7Fw@mail.gmail.com>
	<4ECB95D7.7030702@dti2.net>
	<CAFdo_mXD7by23i38GZHePiHhESpcX66vamBUqHU-fQQFU1RcaA@mail.gmail.com>
	<4ECBB2C4.9000505@dti2.net>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:53895 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757463Ab1KVPwE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:52:04 -0500
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 9976060130
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 16:52:02 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id 3AGuJk+6WVfO for <netdev@vger.kernel.org>;
	Tue, 22 Nov 2011 16:51:58 +0100 (CET)
Received: from mail-gx0-f174.google.com (mail-gx0-f174.google.com [209.85.161.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id 236EF12011A
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 16:51:57 +0100 (CET)
Received: by ggnr5 with SMTP id r5so333374ggn.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 07:51:56 -0800 (PST)
In-Reply-To: <4ECBB2C4.9000505@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> =A0 =A0 =A0 =A0But you failed to provide patches, that fix ONE thing =
at a time, and not a
> patch with all the work that you have done, that's what you sent me f=
or the
> stack overflow bug or have done now with the git tree. Providing clea=
n,
> separated patches it's YOUR work if you WANT to see them applied on t=
he
> mpls-linux tree.
>

It will do that when I have free time.

> =A0 =A0 =A0 =A0You have #ifdefed the MPLS code in the core networking=
 code, that's wrong,
> that's not the way to go if you want to see the code merged upstream.=
 The shim
> layer was thought as a core component of the kernel. If we rip it wha=
t we come
> at with should be #ifdef-less.
>

If the kernel is compiled witout CONFIG_IP_MPLS we would have intact
core networking code.
That was my idea. Why we would need that code if we don't use MPLS?


>>> =A0 =A0 =A0 =A0The other thing that probably I am going to remove i=
s the labelspace support. I
>>> don't see a use for it, and even Cisco doesn't implement it either =
that I know.
>>
>> That's 15 min of work, but I think that labelspaces should stay.
>
> =A0 =A0 =A0 =A0Yes, I dit it an hour ago on a private branch. :) Why =
should did it stay?

Because of RFCs.

> =A0 =A0 =A0 =A0Yes, I did not finish the change code because no ones =
uses it currently
> (iproute, quagga). In my opinion the instructions should be nested at=
tributes,
> and we have to change how the MPLS_CHANGE_* flags get passed, current=
ly it's a hack.
>

I like it this way. Don't see the problem with that part of the code.
BR
Igor
