From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: use const char * for interface name in brcmf_add_if
Date: Wed, 29 Jun 2016 16:00:22 +0000 (UTC)
Message-ID: <20160629160022.BF0C861388@smtp.codeaurora.org>
References: <1466160530-32626-1-git-send-email-zajec5@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466160530-32626-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki wrote:
> This function can work just fine with const pointer, it only calls
> alloc_netdev which take const as well. Moreover it makes this functio=
n
> more flexible as some cfg80211 callback may provide const char * as
> well, e.g. add_virtual_intf. This will be needed for more advanced
> interface management.
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

54264e7ea09a brcmfmac: use const char * for interface name in brcmf_add=
_if

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9183453/
