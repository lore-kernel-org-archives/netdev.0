From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: Disable local BHes to prevent a
 dead-lock situation
Date: Wed, 24 Nov 2010 15:04:04 +0100
Message-ID: <1290607444.3464.39.camel@edumazet-laptop>
References: <1290606310.25676.7.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	netdev list <netdev@vger.kernel.org>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63219 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580Ab0KXOEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:04:11 -0500
Received: by wwa36 with SMTP id 36so9973134wwa.1
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 06:04:10 -0800 (PST)
In-Reply-To: <1290606310.25676.7.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 novembre 2010 =C3=A0 15:45 +0200, Vladislav Zolotarov a
=C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> According to Eric's suggestion:
> Disable local BHes to prevent a dead-lock situation between sch_direc=
t_xmit()
> (Soft_IRQ context) and bnx2x_tx_int (called by bnx2x_run_loopback() -=
 syscall
> context), as both are taking a netif_tx_lock().
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> CCing Eric... :)

Dont worry, I am subscribed to netdev ;)

Thanks !


