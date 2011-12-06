From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: Fix compile errors if CONFIG_CNIC is
 not set
Date: Tue, 06 Dec 2011 22:03:03 +0100
Message-ID: <1323205383.2690.25.camel@edumazet-laptop>
References: <1323205088-29693-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, barak@broadcom.com,
	eilong@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46690 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab1LFVDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:03:08 -0500
Received: by eeaq14 with SMTP id q14so3350521eea.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 13:03:07 -0800 (PST)
In-Reply-To: <1323205088-29693-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 12:58 -0800, Michael Chan a =C3=A9=
crit :
> Don't provide FCoE and iSCSI statistics to management firmware if
> CONFIG_CNIC is not set.  Some needed structure fields are not defined
> without CONFIG_CNIC.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20

Thanks for the fast answer, and yes, no more build error :)
