From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: sfc: an enumeration is not a bitmask
Date: Tue, 17 May 2011 21:09:34 +0200
Message-ID: <BANLkTinaO0VVGpRRqRauH6FucvwbcXyRUg@mail.gmail.com>
References: <20110517.141446.140687548350861625.davem@davemloft.net> <BANLkTi=n_0JiF0Lm=+1OwRzB4XQFBtg8KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:42821 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756385Ab1EQTJz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:09:55 -0400
Received: by qwk3 with SMTP id 3so423927qwk.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 12:09:54 -0700 (PDT)
In-Reply-To: <BANLkTi=n_0JiF0Lm=+1OwRzB4XQFBtg8KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/17 Jeff Garzik <jgarzik@pobox.com>:
> 2011/5/17 David Miller <davem@davemloft.net>:
>> An enumeration is not a bitmask, instead it means one out of the set
>> of enumerated values will be used.
>
> It's a decade-old kernel practice to use 'enum' to define typed
> constants, preferred over =C2=A0macros that convey no type informatio=
n and
> disappear after cpp phase.
>
> So your assertion about enumerations is demonstrably not true, as it
> is often used in the kernel. =C2=A0Call it enum abuse if you want, bu=
t it
> is consistent with code all over the kernel.
>
> That said, I agree that warnings should of course be addressed in som=
e manner.

Old age of the mistake doesn't make it correct.

Disappearance of the #defines can be resolved by using enum of bit
positions (and maybe field lengths) and #define of (1 << bit_position)
if it is useful for something to remain after preprocessing.

Best Regards,
Micha=C5=82 Miros=C5=82aw
