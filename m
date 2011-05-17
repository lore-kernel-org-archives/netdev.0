From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: sfc: an enumeration is not a bitmask
Date: Wed, 18 May 2011 01:19:01 +0200
Message-ID: <BANLkTi=C24pTxhMRtaT40Rrj9Z1s+DH=jg@mail.gmail.com>
References: <20110517.141446.140687548350861625.davem@davemloft.net>
 <BANLkTi=n_0JiF0Lm=+1OwRzB4XQFBtg8KA@mail.gmail.com> <BANLkTinaO0VVGpRRqRauH6FucvwbcXyRUg@mail.gmail.com>
 <4DD2EFEC.9040504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:55367 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab1EQXTW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 19:19:22 -0400
Received: by qwk3 with SMTP id 3so523590qwk.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 16:19:21 -0700 (PDT)
In-Reply-To: <4DD2EFEC.9040504@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 18 maja 2011 00:00 u=BFytkownik Jeff Garzik <jgarzik@pobox.com> =
napisa=B3:
> On 05/17/2011 03:09 PM, Micha=B3 Miros=B3aw wrote:
>> 2011/5/17 Jeff Garzik<jgarzik@pobox.com>:
>>> 2011/5/17 David Miller<davem@davemloft.net>:
>>>> An enumeration is not a bitmask, instead it means one out of the s=
et
>>>> of enumerated values will be used.
>>> It's a decade-old kernel practice to use 'enum' to define typed
>>> constants, preferred over =A0macros that convey no type information=
 and
>>> disappear after cpp phase.
>>>
>>> So your assertion about enumerations is demonstrably not true, as i=
t
>>> is often used in the kernel. =A0Call it enum abuse if you want, but=
 it
>>> is consistent with code all over the kernel.
>> Old age of the mistake doesn't make it correct.
> It is not a mistake, but a useful coding tool.

Being it a mistake does not contradict usefulness. ;-)

C has bitfields for the uses where masks and shifts are usually used.
Unfortunately, those usually require more typing and sometimes compile
to worse code.

Best Regards,
Micha=B3 Miros=B3aw
