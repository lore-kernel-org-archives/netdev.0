From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v3,1/2] b43: Remove unused phy_a code
Date: Thu, 16 Jun 2016 15:23:37 +0000 (UTC)
Message-ID: <20160616152337.3C1BE61418@smtp.codeaurora.org>
References: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org, m@bues.ch,
	Guenter Roeck <linux@roeck-us.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guenter Roeck <linux@roeck-us.net> wrote:
> gcc-6 reports the following error with -Werror=3Dunused-const-variabl=
e.
>=20
> drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
> 	'b43_phyops_a' defined but not used
>=20
> Per Michael B=C3=BCsch: "All a-phy code is usused", so remove it all,
> and move the remaining Type-G initialization code into phy_g.c.
>=20
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> Cc: Michael B=C3=BCsch <m@bues.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Thanks, 2 patches applied to wireless-drivers-next.git:

9791333a840f b43: Remove unused phy_a code
afdfdc481ea9 b43: Completely remove support for phy_a

--=20
Sent by pwcli
https://patchwork.kernel.org/patch/9154719/
