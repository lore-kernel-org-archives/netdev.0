From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Tue, 20 Dec 2011 12:02:52 -0800
Message-ID: <CAGK4HS9LuvgOoY+cSXq-Vjbx7x5gsQ03wj6Tb1UDsO=89Wkrpw@mail.gmail.com>
References: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AF1C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ilpo.jarvinen@helsinki.fi, "H.K. Jerry Chu" <hkchu@google.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:38222 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab1LTUCx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 15:02:53 -0500
Received: by vcbfk14 with SMTP id fk14so5198445vcb.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 12:02:52 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF1C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for reviewing the patch. Please see responses below.

On 20 December 2011 02:27, David Laight <David.Laight@aculab.com> wrote=
:
>
>> +/*These are used to set the sack_ok field in struct
>> tcp_options_received */
>> +#define SACK_SEEN =A0 =A0 (1 << 0) =A0 /*1 =3D peer is SACK capable=
, */
>> +#define FACK_ENABLED =A0(1 << 1) =A0 /*1 =3D FACK is enabled locall=
y*/
>> +#define DSACK_SEEN =A0 =A0(1 << 2) =A0 /*1 =3D DSACK was received f=
rom peer*/
>> +
>
> Since that is a fairly public header, some namespace protection
> might be sensible.

I assume you are talking about collision with userspace.  These
definitions are already protected by #ifdef  __KERNEL__.
That should be enough to protect against collisions with userspace I th=
ink.

>
>> - =A0 =A0 tcp_opt->sack_ok =3D (options >> 4) & 0x1;
>> + =A0 =A0 tcp_opt->sack_ok =3D (options >> 4) & SACK_SEEN;
>
> Looks to me like that 0x1 isn't SAC_SEEK! So this is now misleading.

Can you please elaborate? Are you saying this is wrong or that it
could be done better?

Thanks for your time!
Vijay
