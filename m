From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2: Update driver to use new mips firmware.
Date: Wed, 21 Dec 2011 09:53:27 +0100
Message-ID: <1324457607.2728.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324268109-27740-1-git-send-email-mchan@broadcom.com>
	 <20111219.154804.255413353396711289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:63907 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1LUIxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 03:53:30 -0500
Received: by vbbfc26 with SMTP id fc26so5590676vbb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 00:53:30 -0800 (PST)
In-Reply-To: <20111219.154804.255413353396711289.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 d=C3=A9cembre 2011 =C3=A0 15:48 -0500, David Miller a =C3=A9=
crit :
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Sun, 18 Dec 2011 20:15:09 -0800
>=20
> > bnx2-mips-06-6.2.3 and bnx2-mips-09-6.2.1.b
> >=20
> > New firmware fixes iSCSI problems with some LeftHand targets that d=
on't
> > set TTT=3D0xffffffff for Data-In according to spec.  Firmware gener=
ates
> > exception warnings for this condition and becomes very slow.  This =
is
> > fixed by suppressing these warnings when using default error mask.
> >=20
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
>=20
> Applied.
> --

But... where I am supposed to find this firmware ?

Its _not_ in linux-firmware right now

[  259.352808] bnx2: Can't load firmware file "bnx2/bnx2-mips-06-6.2.3.=
fw"
[  897.157266] bnx2: Can't load firmware file "bnx2/bnx2-mips-06-6.2.3.=
fw"
[ 1019.944049] bnx2: Can't load firmware file "bnx2/bnx2-mips-06-6.2.3.=
fw"
