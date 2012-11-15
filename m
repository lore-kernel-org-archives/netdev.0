From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: fix tasklet misuse issue
Date: Wed, 14 Nov 2012 21:50:55 -0500 (EST)
Message-ID: <20121114.215055.1156530698069105896.davem@davemloft.net>
References: <1352872056-5637-1-git-send-email-xtfeng@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dannyfeng@tencent.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xtfeng@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352872056-5637-1-git-send-email-xtfeng@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaotian Feng <xtfeng@gmail.com>
Date: Wed, 14 Nov 2012 13:47:36 +0800

> In commit 175c0dff, drivers uses tasklet_kill to avoid put disabled tasklet
> on the tasklet vec. But some of the drivers uses tasklet_init & tasklet_disable
> in the driver init code, then tasklet_enable when it is opened. This makes
> tasklet_enable on a killed tasklet and make ksoftirqd crazy then. Normally,
> drivers should use tasklet_init/tasklet_kill on device open/remove, and use
> tasklet_disable/tasklet_enable on device suspend/resume.
> 
> Reported-by: Peter Wu <lekensteyn@gmail.com>
> Tested-by: Peter Wu <lekensteyn@gmail.com>
> Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>

Applied, thanks.
