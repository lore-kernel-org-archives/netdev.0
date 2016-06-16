From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: include required headers in cfg80211.h
Date: Thu, 16 Jun 2016 15:26:52 +0000 (UTC)
Message-ID: <20160616152652.ED17F61418@smtp.codeaurora.org>
References: <1465280428-5782-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: =?utf-8?b?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465280428-5782-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki wrote:
> Without this including cfg80211.h in a wrong order could result in:
>=20
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:122:24: e=
rror: array type has incomplete element type
>   struct brcmf_wsec_key key[BRCMF_MAX_DEFAULT_KEYS];
>                         ^
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:291:24: e=
rror: field =E2=80=98p2p=E2=80=99 has incomplete type
>   struct brcmf_p2p_info p2p;
>                         ^
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:297:27: e=
rror: field =E2=80=98pmk_list=E2=80=99 has incomplete type
>   struct brcmf_pmk_list_le pmk_list;
>                            ^
> drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:317:28: e=
rror: field =E2=80=98assoclist=E2=80=99 has incomplete type
>   struct brcmf_assoclist_le assoclist;
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

29477269a27d brcmfmac: include required headers in cfg80211.h

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9159889/
