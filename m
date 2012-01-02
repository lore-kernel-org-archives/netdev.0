From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] sch_qfq: fix overflow in qfq_update_start()
Date: Mon, 2 Jan 2012 22:56:27 +0100
Message-ID: <CAA93jw49WSxU1tATiB1nQJRLvwHXJOaHq2t_1+Kp-Eb9FzS=rA@mail.gmail.com>
References: <1325519277.2375.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325540706.2874.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63451 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab2ABV42 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 16:56:28 -0500
Received: by iaeh11 with SMTP id h11so29847320iae.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 13:56:28 -0800 (PST)
In-Reply-To: <1325540706.2874.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2012 at 10:45 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 02 janvier 2012 =E0 16:47 +0100, Eric Dumazet a =E9crit :
>> grp->slot_shift is between 22 and 41, so using 32bit wide variables =
is
>> probably a typo.
>>
>> This could explain QFQ hangs Dave reported to me, after 2^23 packets=
 ?
>>
>> (23 =3D 64 - 41)
>>
>> Reported-by: Dave Taht <dave.taht@gmail.com>
>> CC: Stephen Hemminger <shemminger@vyatta.com>
>> CC: Dave Taht <dave.taht@gmail.com>
>
> Oh well, I forgot my SOB :(
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> David please just tell me if you prefer me to resend it
>
>

I figure I'm the wrong david, but I'll be testing the QFQ patch overnig=
ht.
I have tested it for about an hour thus far.

Your SFQ patch, posted earlier today, does bring SFQ and QFQ back
into equivalence at 10 iperfs.

http://www.teklibre.com/~d/bloat/sfqnewvsqfq10iperfs.png

Well done.

--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
