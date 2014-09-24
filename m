From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: Q: State of Linux RSTP support
Date: Wed, 24 Sep 2014 14:23:54 -0400
Message-ID: <54230C3A.6030802@gmail.com>
References: <542306A2.7020008@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:41555 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbaIXSX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:23:57 -0400
Received: by mail-qc0-f178.google.com with SMTP id x13so3799557qcv.23
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 11:23:56 -0700 (PDT)
In-Reply-To: <542306A2.7020008@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/24/2014 02:00 PM, Tilman Schmidt wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> According to Stephen Hemminger's presentation at
> http://www.slideshare.net/shemminger/new-bridge (which seems to be th=
e
> most recent information available on the topic) the in-kernel bridgin=
g
> code only provides STP. RTSP is (should be) provided by a user space
> daemon, rtspd. However, none of the distributions I routinely use
> provide that daemon. Sourceforge has a project named rstpd but it
> seems to be inactive.
>=20
> A search for RSTP in the current git tree finds
>=20
> - - in net/bridge/br_netlink.c, a comment:
>                       /* Binary compatibility with old RSTP */
>=20
> - - in net/bridge/br_private.h, an enum constant for struct net_bridg=
e
> member stp_enabled:
>               BR_USER_STP,            /* new RSTP in userspace */
>=20
> but nothing in, say, the Documentation folder.

There is https://git.kernel.org/cgit/linux/kernel/git/shemminger/rstp.g=
it/
but it's 3 years old.  Don't know if Stephen has anything newer.

-vlad

>=20
> Any pointers?
>=20
> aTdHvAaNnKcSe,
> Tilman
>=20
> - --=20
> Tilman Schmidt                              E-Mail: tilman@imap.cc
> Bonn, Germany
> Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
> Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v2
>=20
> iQEcBAEBAgAGBQJUIwaiAAoJEFPuqx0v+F+q/dIIAI8tK2C7yVPoD3PaLwwVqcxQ
> 9lV3VCXiRT4v1fGTqEtzTJhoyPAqZw+iHbmoPVZow9GPEAS1m5nPYBE44cejmP6M
> SL0OtQmcnYO0UNBsIpwA6F8g+e3ZraivtAv4CVoBLMXGWrAz7zrERIRTkk0XOMdG
> t2Is1e+U+48DlOH8CIPhqOEu/kIABz2GMle5S94VzlBkeBsGL9ifDrFxACtxbkEN
> YJIm9QKxZa/MGwksgHCoQWDafrcs8RL6FhQDBVCUVhrERlp/12+kKwYXxvH9kv+a
> YAAzMXkAu+3zPTI0Bl99M4NEQ57Z0FKtb8pwug9wSKH7UWdx18pKYOsYUdMwROM=3D
> =3Ds37Z
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
