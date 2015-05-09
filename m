From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: do not return success when command times out
Date: Sat,  9 May 2015 13:47:44 +0000 (UTC)
Message-ID: <20150509134744.C0E9D14011B@smtp.codeaurora.org>
References: <20150430235202.GA35256@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Avinash Patil <patila@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150430235202.GA35256@dtor-ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> wait_event_interruptible_timeout() returns 0 upon timeout. We should
> convert it to a negative error code (such as -ETIMEDOUT) instead of
> returning it directly, as return code of 0 indicates that command was
> executed.
> 
> Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
