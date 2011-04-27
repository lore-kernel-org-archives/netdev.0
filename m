From: "George B." <georgeb@gmail.com>
Subject: Re: [PATCH] tcp: disallow bind() to reuse addr/port
Date: Wed, 27 Apr 2011 10:37:54 -0700
Message-ID: <BANLkTi=176iFKUHn351OWOZUSaUBkgKf2Q@mail.gmail.com>
References: <1294140172.3579.81.camel@edumazet-laptop>
	<AANLkTimuNM7vmeR89WKXtrUbJO1Wt1ivp9y=bQvtWg0j@mail.gmail.com>
	<1294744462.2927.53.camel@edumazet-laptop>
	<20110111.140336.128591591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, daniel.baluta@gmail.com,
	gasparch@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:55314 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab1D0Rh4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:37:56 -0400
Received: by wwk4 with SMTP id 4so3542945wwk.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 10:37:54 -0700 (PDT)
In-Reply-To: <20110111.140336.128591591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 11, 2011 at 2:03 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 11 Jan 2011 12:14:22 +0100
>
>> [PATCH] tcp: disallow bind() to reuse addr/port
>>
>> inet_csk_bind_conflict() logic currently disallows a bind() if
>> it finds a friend socket (a socket bound on same address/port)
>> satisfying a set of conditions :
>>
>> 1) Current (to be bound) socket doesnt have sk_reuse set
>> OR
>> 2) other socket doesnt have sk_reuse set
>> OR
>> 3) other socket is in LISTEN state
>>
>> We should add the CLOSE state in the 3) condition, in order to avoid=
 two
>> REUSEADDR sockets in CLOSE state with same local address/port, since
>> this can deny further operations.
>>
>> Note : a prior patch tried to address the problem in a different (an=
d
>> buggy) way. (commit fda48a0d7a8412ced tcp: bind() fix when many port=
s
>> are bound).
>>
>> Reported-by: Gaspar Chilingarov <gasparch@gmail.com>
>> Reported-by: Daniel Baluta <daniel.baluta@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>
> Applied, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

OK, just saw this, so please disregard my earlier.

George
