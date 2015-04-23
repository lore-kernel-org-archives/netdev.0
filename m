From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][FIX 4.1] bgmac: fix requests for extra polling calls
 from NAPI
Date: Thu, 23 Apr 2015 12:06:50 -0700
Message-ID: <1429816010.22254.82.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429815389-17265-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:34033 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030481AbbDWTGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 15:06:52 -0400
Received: by iedfl3 with SMTP id fl3so76648275ied.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 12:06:51 -0700 (PDT)
In-Reply-To: <1429815389-17265-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 20:56 +0200, Rafa=C5=82 Mi=C5=82ecki wrote:
> After d75b1ade567f ("net: less interrupt masking in NAPI") polling
> function has to return whole budget when it wants NAPI to call it aga=
in.
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Cc: Felix Fietkau <nbd@openwrt.org>
> Fixes: eb64e2923a886 ("bgmac: leave interrupts disabled as long as th=
ere is work to do")
> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks !
