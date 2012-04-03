From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3,1/1] net/hyperv: Add flow control based on hi/low
 watermark
Date: Tue, 03 Apr 2012 17:48:14 -0400 (EDT)
Message-ID: <20120403.174814.1643372599291158711.davem@davemloft.net>
References: <1332890445-12562-1-git-send-email-haiyangz@microsoft.com>
	<1332890445-12562-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332890445-12562-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 27 Mar 2012 16:20:45 -0700

> In the existing code, we only stop queue when the ringbuffer is full,
> so the current packet has to be dropped or retried from upper layer.
> 
> This patch stops the tx queue when available ringbuffer is below
> the low watermark. So the ringbuffer still has small amount of space
> available for the current packet. This will reduce the overhead of
> retries on sending.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied to net-next
