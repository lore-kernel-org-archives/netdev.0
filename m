From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH][FIX 4.1] bgmac: fix requests for extra polling calls
 from NAPI
Date: Thu, 23 Apr 2015 21:00:04 +0200
Message-ID: <55394134.3070505@openwrt.org>
References: <1429815389-17265-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:44297 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030609AbbDWTAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 15:00:10 -0400
In-Reply-To: <1429815389-17265-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-23 20:56, Rafa=C5=82 Mi=C5=82ecki wrote:
> After d75b1ade567f ("net: less interrupt masking in NAPI") polling
> function has to return whole budget when it wants NAPI to call it aga=
in.
>=20
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> Cc: Felix Fietkau <nbd@openwrt.org>
> Fixes: eb64e2923a886 ("bgmac: leave interrupts disabled as long as th=
ere is work to do")
Acked-by: Felix Fietkau <nbd@openwrt.org>

- Felix
