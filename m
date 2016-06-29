From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: add missing break when deleting P2P_DEVICE
Date: Wed, 29 Jun 2016 16:02:12 +0000 (UTC)
Message-ID: <20160629160212.42D5461385@smtp.codeaurora.org>
References: <1466294168-8890-1-git-send-email-zajec5@gmail.com>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:41272 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbcF2QCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 12:02:12 -0400
In-Reply-To: <1466294168-8890-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafa=C5=82 Mi=C5=82ecki wrote:
> We obviously don't want to fall through in that switch. With this cha=
nge
> 1) We wait for event (triggered by p2p_disc) as expected
> 2) We remove interface manually on timeout
> 3) We return 0 on success instead of -ENOTSUPP
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

20856adf2280 brcmfmac: add missing break when deleting P2P_DEVICE

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9185903/
