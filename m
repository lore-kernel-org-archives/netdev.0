From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wlcore: fix error handling in wlcore_event_fw_logger
Date: Fri, 29 Jan 2016 09:15:20 +0000 (UTC)
Message-ID: <20160129091520.9A0D76045B@smtp.codeaurora.org>
References: <1452173330-19963-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shahar Patury <shaharp@ti.com>,
	linux-wireless@vger.kernel.org (open list:TI WILINK WIRELESS DRIVERS),
	Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Andrzej Hajda <a.hajda@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452173330-19963-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> wlcore_read/wlcore_write can return negative values so it should
> be assigned to signed variable.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2120705
> 
> Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
