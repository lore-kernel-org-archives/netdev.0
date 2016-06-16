From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V2] brcmfmac: fix setting AP channel with new firmwares
Date: Thu, 16 Jun 2016 15:07:33 +0000 (UTC)
Message-ID: <20160616150733.8C8546141F@smtp.codeaurora.org>
References: <1464376045-8220-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464376045-8220-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki wrote:
> Firmware for new chipsets is based on a new major version of code
> internally maintained at Broadcom. E.g. brcmfmac4366b-pcie.bin (used =
for
> BCM4366B1) is based on 10.10.69.3309 while brcmfmac43602-pcie.ap.bin =
was
> based on 7.35.177.56.
>=20
> Currently setting AP 5 GHz channel doesn't work reliably with BCM4366=
B1.
> When setting e.g. 36 control channel with VHT80 (center channel 42)
> firmware may randomly pick one of:
> 1) 52 control channel with 58 as center one
> 2) 100 control channel with 106 as center one
> 3) 116 control channel with 122 as center one
> 4) 149 control channel with 155 as center one
>=20
> It seems new firmwares require setting AP mode (BRCMF_C_SET_AP) befor=
e
> specifying a channel. Changing an order of firmware calls fixes the
> problem. This requirement resulted in two separated "chanspec" calls,
> one in AP code path and one in P2P path.
>=20
> This fix was verified with BCM4366B1 and tested for regressions on
> BCM43602.
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

8707e08dbc1f brcmfmac: fix setting AP channel with new firmwares

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9138883/
