From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mwifiex: add __GFP_REPEAT to skb allocation call
Date: Tue, 29 Mar 2016 11:37:51 +0300
Message-ID: <87vb45brxc.fsf@kamboji.qca.qualcomm.com>
References: <1459226840-36287-1-git-send-email-wnhuang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>, snanda@google.com,
	netdev@vger.kernel.org
To: Wei-Ning Huang <wnhuang@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459226840-36287-1-git-send-email-wnhuang@chromium.org>
	(Wei-Ning Huang's message of "Tue, 29 Mar 2016 12:47:20 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei-Ning Huang <wnhuang@chromium.org> writes:

> "single skb allocation failure" happens when system is under heavy
> memory pressure.  Add __GFP_REPEAT to skb allocation call so kernel
> attempts to reclaim pages and retry the allocation.
>
> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>

Is this really a proper way to fix the issue? This is the first time I'm
hearing about the flag and there isn't even a single user in
drivers/net. I would like to get confirmation from others that
__GFP_REPEAT is really ok to use in a wireless driver before I can take
this.

-- 
Kalle Valo
