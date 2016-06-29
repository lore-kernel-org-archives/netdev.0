From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: include also core.h header in cfg80211.h
Date: Wed, 29 Jun 2016 16:01:14 +0000 (UTC)
Message-ID: <20160629160114.BA16461388@smtp.codeaurora.org>
References: <1466268596-12178-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41111 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcF2QBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:01:15 -0400
In-Reply-To: <1466268596-12178-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafa=C5=82 Mi=C5=82ecki wrote:
> This header provides two inline functions using struct brcmf_if so we
> need core.h to avoid:
>=20
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h: In funct=
ion =E2=80=98ndev_to_prof=E2=80=99:
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:368:13: e=
rror: dereferencing pointer to incomplete type
>   return &ifp->vif->profile;
>              ^
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h: In funct=
ion =E2=80=98ndev_to_vif=E2=80=99:
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:374:12: e=
rror: dereferencing pointer to incomplete type
>   return ifp->vif;
>             ^
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

bda9d01427f5 brcmfmac: include also core.h header in cfg80211.h

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9185755/
