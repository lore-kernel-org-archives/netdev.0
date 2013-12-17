From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unix: allow bind to fail on mutex lock
Date: Tue, 17 Dec 2013 15:04:56 -0500 (EST)
Message-ID: <20131217.150456.1467555049218669410.davem@davemloft.net>
References: <1386950062-19020-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386950062-19020-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Fri, 13 Dec 2013 10:54:22 -0500

> This is similar to the set_peek_off patch where calling bind while the
> socket is stuck in unix_dgram_recvmsg() will block and cause a hung task
> spew after a while.
> 
> This is also the last place that did a straightforward mutex_lock(), so
> there shouldn't be any more of these patches.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
