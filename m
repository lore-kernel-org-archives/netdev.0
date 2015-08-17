From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: phy: workaround for buggy cable detection by
 LAN8700 after cable plugging
Date: Mon, 17 Aug 2015 14:28:34 -0700 (PDT)
Message-ID: <20150817.142834.960620594778281556.davem@davemloft.net>
References: <1439572262-10705-1-git-send-email-plyatov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, joe@perches.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, u.kleine-koenig@pengutronix.de,
	Fabio.Estevam@freescale.com, LW@KARO-electronics.de,
	Frank.Li@freescale.com, mhei@heimpold.de
To: plyatov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439572262-10705-1-git-send-email-plyatov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igor Plyatov <plyatov@gmail.com>
Date: Fri, 14 Aug 2015 20:11:02 +0300

> * Due to HW bug, LAN8700 sometimes does not detect presence of energy in the
>   Ethernet cable in Energy Detect Power-Down mode (e.g while EDPWRDOWN bit is
>   set, the ENERGYON bit does not asserted sometimes). This is a common bug of
>   LAN87xx family of PHY chips.
> * The lan87xx_read_status() was improved to acquire ENERGYON bit. Its previous
>   algorythm still not reliable on 100 % and sometimes skip cable plugging.
> 
> Signed-off-by: Igor Plyatov <plyatov@gmail.com>

Applied, thanks.
