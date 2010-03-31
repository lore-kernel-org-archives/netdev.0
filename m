From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Wed, 31 Mar 2010 10:15:02 +0200
Message-ID: <20100331081502.GQ2241@pengutronix.de>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com> <20100331075746.GO2241@pengutronix.de> <20100331081004.GB23391@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Wu <bryan.wu@canonical.com>, gerg@uclinux.org,
	amit.kucheria@canonical.com, kernel-team@lists.ubuntu.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100331081004.GB23391@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2010 at 10:10:04AM +0200, Wolfram Sang wrote:
> > With rounding this would be:
> > 
> > (clk_get_rate() + 4999999) / 5000000
> 
> Better use DIV_ROUND_UP(clk_get_rate(), 5000000)?

Yes.
Sometimes I wish the useful assorted kernel helper of the day in my
fortune :)

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
