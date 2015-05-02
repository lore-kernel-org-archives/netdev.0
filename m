From: Wolfgang Walter <linux@stwm.de>
Subject: Fwd: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Sat, 02 May 2015 14:48 +0200
Message-ID: <2825292.AkPmz4KpQo@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:48228 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752081AbbEBMx6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 08:53:58 -0400
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 3lf9GS5zJsz2hYn
	for <netdev@vger.kernel.org>; Sat,  2 May 2015 14:48:00 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Sent it originally to lkml instead of nedev]

Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> Hello,
>=20
> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute6 wit=
h an
> isatap-tunnel.

I did some further tests. To trigger the crash you need

* isatap-tunnel (probably any sit-tunnel will do it)
* raw-socket
* udp

Using icmpv6 or tcp i.e. does not trigger it.

>=20
> I took an image of the message I got. It is not complete as my vt has=
 not
> enough lines.
>=20
> 3.19.3 works fine.
>=20
> Regards,

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
