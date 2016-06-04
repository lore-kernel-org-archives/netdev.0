From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH v3 1/2] b43: Remove unused phy_a code
Date: Sat, 4 Jun 2016 16:23:27 -0500
Message-ID: <575346CF.9040003@lwfinger.net>
References: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org, m@bues.ch
To: Guenter Roeck <linux@roeck-us.net>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465052053-26740-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/2016 09:54 AM, Guenter Roeck wrote:
> gcc-6 reports the following error with -Werror=3Dunused-const-variabl=
e.
>
> drivers/net/wireless/broadcom/b43/phy_a.c:576:40: error:
> 	'b43_phyops_a' defined but not used
>
> Per Michael B=C3=BCsch: "All a-phy code is usused", so remove it all,
> and move the remaining Type-G initialization code into phy_g.c.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> Cc: Michael B=C3=BCsch <m@bues.ch>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
> v3: Do not rename b43_phy_inita()
> v2: Remove phy_a.c; move left-over code into phy_g.c
>      Remove now unused data structure

These two patches have been tested on a BCM4318.

Larry
