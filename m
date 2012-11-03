From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: use tasklet_kill in device remove/close
 process
Date: Sat, 03 Nov 2012 15:16:02 -0400 (EDT)
Message-ID: <20121103.151602.1818450049632367167.davem@davemloft.net>
References: <1351679397-26994-1-git-send-email-xtfeng@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dannyfeng@tencent.com,
	netdev@vger.kernel.org
To: xtfeng@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab2KCTQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:16:04 -0400
In-Reply-To: <1351679397-26994-1-git-send-email-xtfeng@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaotian Feng <xtfeng@gmail.com>
Date: Wed, 31 Oct 2012 18:29:57 +0800

> Some driver uses tasklet_disable in device remove/close process,
> tasklet_disable will inc tasklet->count and return. If the tasklet
> is not handled yet because some softirq pressure, the tasklet will
> placed on the tasklet_vec, never have a chance to excute. This might
> lead to ksoftirqd heavy loaded, wakeup with pending_softirq, but
> tasklet is disabled. tasklet_kill should be used in this case.
> 
> Signed-off-by: Xiaotian Feng <dannyfeng@tencent.com>

Applied.
