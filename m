From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: disable irq at first before schedule rx
Date: Fri, 06 Feb 2009 01:32:14 -0800 (PST)
Message-ID: <20090206.013214.132906308.davem@davemloft.net>
References: <498BC3A8.9040203@kernel.org>
	<498BC412.3090900@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mingo@elte.hu, akpm@linux-foundation.org,
	aabdulla@nvidia.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757990AbZBFJcj@vger.kernel.org>
In-Reply-To: <498BC412.3090900@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yinghai Lu <yinghai@kernel.org>
Date: Thu, 05 Feb 2009 21:01:06 -0800

> 
> Impact: clean up
> 
> schedule it later after disable it.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Applied to net-next-2.6

I had to edit this patch to make it apply properly.  In net-next-2.6
the netix_rx_*() have been renamed to napi_*() and the former interfaces
deleted.

Please generate your patches properly against net-next-2.6 in the
future.

Thanks.
