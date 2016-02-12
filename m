From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wlcore: Fix regression in wlcore_set_partition()
Date: Fri, 12 Feb 2016 09:45:26 +0000 (UTC)
Message-ID: <20160212094526.EC572611CE@smtp.codeaurora.org>
References: <20160210012216.GA18819@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Shahar Patury <shaharp@ti.com>, Guy Mishol <guym@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	Ross Green <rgkernel@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Emil Goode <emil.fsw@goode.io>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160210012216.GA18819@lianli>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The commit 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio") introduced a
> regression causing the wlcore to time out and go into recovery. Reverting the
> changes regarding write of the last partition size brings the module back to
> it's functional state.
> 
> Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
> Reported-by: Ross Green <rgkernel@gmail.com>
> Signed-off-by: Emil Goode <emil.fsw@goode.io>
> [kvalo@codeaurora.org: improved commit log]

Thanks, applied to wireless-drivers.git.

Kalle Valo
