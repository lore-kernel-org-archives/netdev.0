From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Wed, 21 Dec 2011 11:43:45 -0800
Message-ID: <CAGK4HS-bWp4ju6LybJ7JeVbyTxH0Xg_g=Fh3PtwMsT4BUQkjEQ@mail.gmail.com>
References: <20111220.151809.1704705119739851376.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6D8AF1E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi, hkchu@google.com
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:39606 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463Ab1LUTnp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:43:45 -0500
Received: by vbbfc26 with SMTP id fc26so6080121vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 11:43:45 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF1E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Given the values are currently:
>
>> > +#define SACK_SEEN =A0 =A0 (1 << 0) =A0 /*1 =3D peer is SACK capab=
le, */
>> > +#define FACK_ENABLED =A0(1 << 1) =A0 /*1 =3D FACK is enabled loca=
lly*/
>> > +#define DSACK_SEEN =A0 =A0(1 << 2) =A0 /*1 =3D DSACK was received=
 from
> peer*/
>
> But the structure field member is 'sack_ok', unless it generates
> very silly long lines - which in this case it probably doesn't -
> it might even be worth prefixing with TCP_SACK_OK_ although
> that might be deemed excessive!
>

Thanks for all the feedback. I will follow these suggestions in future.

Vijay
