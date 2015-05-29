From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: systemport: rewrite bcm_sysport_rx_refill
Date: Thu, 28 May 2015 21:02:30 -0700
Message-ID: <5567E4D6.3030409@gmail.com>
References: <1432851884-12026-1-git-send-email-f.fainelli@gmail.com>	<1432851884-12026-3-git-send-email-f.fainelli@gmail.com> <CAGXr9JEEGSVKVgqzNTWePytjiFCqK32k4YWZGtORskW5H3Atbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34927 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbE2ECc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 00:02:32 -0400
Received: by obcnx10 with SMTP id nx10so43363352obc.2
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 21:02:32 -0700 (PDT)
In-Reply-To: <CAGXr9JEEGSVKVgqzNTWePytjiFCqK32k4YWZGtORskW5H3Atbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/28/15 20:58, Petri Gynther a =C3=A9crit :
[snip]

>>                 /* We do not have a backing SKB, so we do not a corr=
esponding
>=20
> Is this comment still valid? I removed it from bcmgenet.

Not really, thanks, I will fix that in v2.

[snip]

>> +
>> +               if (priv->rx_read_ptr =3D=3D priv->num_rx_bds)
>=20
> if (unlikely(priv->rx_read_ptr =3D=3D priv->num_rx_bds))

Will fix that as well, thank you!
--=20
=46lorian
