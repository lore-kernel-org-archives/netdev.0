From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] rtlwifi: fix memory leak for USB device
Date: Fri, 11 Dec 2015 11:49:14 +0000 (UTC)
Message-ID: <20151211114914.D9353141D2E@smtp.codeaurora.org>
References: <1449446851-2221-1-git-send-email-peter@lekensteyn.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Peter Wu <peter@lekensteyn.nl>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1449446851-2221-1-git-send-email-peter@lekensteyn.nl>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Free skb for received frames with a wrong checksum. This can happen
> pretty rapidly, exhausting all memory.
> 
> This fixes a memleak (detected with kmemleak). Originally found while
> using monitor mode, but it also appears during managed mode (once the
> link is up).
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Peter Wu <peter@lekensteyn.nl>
> ACKed-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
