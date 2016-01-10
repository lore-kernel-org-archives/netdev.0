From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: prevent writes to cookie_hmac_alg from
 accessing invalid memory
Date: Sun, 10 Jan 2016 18:01:36 -0500 (EST)
Message-ID: <20160110.180136.2132125441173496753.davem@davemloft.net>
References: <1452196363-30954-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452196363-30954-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Thu,  7 Jan 2016 14:52:43 -0500

> proc_dostring() needs an initialized destination string, while the one
> provided in proc_sctp_do_hmac_alg() contains stack garbage.
> 
> Thus, writing to cookie_hmac_alg would strlen() that garbage and end up
> accessing invalid memory.
> 
> Fixes: 3c68198e7 ("sctp: Make hmac algorithm selection for cookie generation dynamic")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied and queued up for -stable, thanks.
