From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH linux-firmware] linux-firmware: bnx2: Update mips
 firmware to fix iSCSI problems
Date: Wed, 21 Dec 2011 09:55:26 +0100
Message-ID: <1324457726.2728.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324268012-27719-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:34388 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab1LUIza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 03:55:30 -0500
Received: by vcbfk14 with SMTP id fk14so5545970vcb.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 00:55:28 -0800 (PST)
In-Reply-To: <1324268012-27719-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 18 d=C3=A9cembre 2011 =C3=A0 20:13 -0800, Michael Chan a =C3=
=A9crit :
> New firmware fixes iSCSI problems with some LeftHand targets that don=
't
> set TTT=3D0xffffffff for Data-In according to spec.  Firmware generat=
es
> exception warnings for this condition and becomes very slow.  This is
> fixed by suppressing these warnings when using default error mask.
>=20
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  WHENCE                      |    2 ++
>  bnx2/bnx2-mips-06-6.2.3.fw  |  Bin 0 -> 92824 bytes
>  bnx2/bnx2-mips-09-6.2.1b.fw |  Bin 0 -> 103904 bytes
>  3 files changed, 2 insertions(+), 0 deletions(-)
>  create mode 100644 bnx2/bnx2-mips-06-6.2.3.fw
>  create mode 100644 bnx2/bnx2-mips-09-6.2.1b.fw

IMHO, this should be applied _before_ the drivers/net patch.
