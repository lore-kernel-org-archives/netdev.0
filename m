From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH] ath9k: Fix uninitialized variable in ath9k_has_tx_pending()
Date: Thu, 30 Jan 2014 07:55:19 +0100
Message-ID: <52E9F757.3040306@openwrt.org>
References: <1390733601-11244-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390733601-11244-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014-01-26 11:53, Geert Uytterhoeven wrote:
> drivers/net/wireless/ath/ath9k/main.c: In function =E2=80=98ath9k_has=
_tx_pending=E2=80=99:
> drivers/net/wireless/ath/ath9k/main.c:1869: warning: =E2=80=98npend=E2=
=80=99 may be used uninitialized in this function
>=20
> Introduced by commit 10e2318103f5941aa70c318afe34bc41f1b98529 ("ath9k=
:
> optimize ath9k_flush").
>=20
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Felix Fietkau <nbd@openwrt.org>
