From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ppp: remove unnecessary bh disable in xmit
 path
Date: Thu, 01 Jun 2017 12:01:04 -0400 (EDT)
Message-ID: <20170601.120104.1498917277276131903.davem@davemloft.net>
References: <1496311119-59204-1-git-send-email-gfree.wind@vip.163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, g.nault@alphalink.fr,
        netdev@vger.kernel.org
To: gfree.wind@vip.163.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1496311119-59204-1-git-send-email-gfree.wind@vip.163.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: gfree.wind@vip.163.com
Date: Thu,  1 Jun 2017 17:58:39 +0800

> From: Gao Feng <gfree.wind@vip.163.com>
> 
> Since the commit 55454a565836 ("ppp: avoid dealock on recursive xmit"),
> the PPP xmit path is protected by wrapper functions which disable the
> bh already. So it is unnecessary to disable the bh again in the real
> xmit path.
> 
> Signed-off-by: Gao Feng <gfree.wind@vip.163.com>

Applied, thank you.
