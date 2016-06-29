From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: slightly simplify building interface combinations
Date: Wed, 29 Jun 2016 15:41:52 +0000 (UTC)
Message-ID: <20160629154152.8E340613A6@smtp.codeaurora.org>
References: <1465326626-365-1-git-send-email-zajec5@gmail.com>
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
In-Reply-To: <1465326626-365-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki wrote:
> This change reorders some operations in brcmf_setup_ifmodes in hope t=
o
> make it simpler:
> 1) It allocates arrays right before filling them. This way it's easie=
r
>    to follow requested array length as it's immediately followed by
>    code filling it. It's easier to check e.g. why we need 4 entries f=
or
>    P2P. Other than that it deduplicates some checks (e.g. for P2P).
> 2) It reorders code to first prepare limits and then define a new com=
bo.
>    Previously this was mixed (e.g. we were setting num of channels
>    before preparing limits).
> 3) It modifies mbss code to use i variable just like other combos do.
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

f568adac7d1a brcmfmac: slightly simplify building interface combination=
s

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9162267/
