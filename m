From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wlcore: Fix regression in wlcore_set_partition()
Date: Wed, 10 Feb 2016 19:34:16 +0200
Message-ID: <87k2mctqp3.fsf@kamboji.qca.qualcomm.com>
References: <20160210012216.GA18819@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shahar Patury <shaharp@ti.com>, Guy Mishol <guym@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	Ross Green <rgkernel@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Emil Goode <emil.fsw@goode.io>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160210012216.GA18819@lianli> (Emil Goode's message of "Wed, 10
	Feb 2016 02:22:16 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emil Goode <emil.fsw@goode.io> writes:

> The below commit introduced a regression causing the wlcore
> to time out and go into recovery.
>
> commit 3719c17e1816695f415dd3b4ddcb679f7dc617c8
> ("wlcore/wl18xx: fw logger over sdio")
>
> Reverting the changes regarding write of the last partition size
> brings the module back to it's functional state.
>
> Reported-by: Ross Green <rgkernel@gmail.com>
> Signed-off-by: Emil Goode <emil.fsw@goode.io>

A proper "Fixes:" line is good to have, but I can add it.

I'm planning to queue this to 4.5.

-- 
Kalle Valo
