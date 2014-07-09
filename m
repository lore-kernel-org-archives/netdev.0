From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] xen-netback: Adding debugfs "io_ring_qX"
 files
Date: Tue, 08 Jul 2014 20:49:15 -0700 (PDT)
Message-ID: <20140708.204915.1577238573149775056.davem@davemloft.net>
References: <1404845354-16237-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404845354-16237-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Tue, 8 Jul 2014 19:49:14 +0100

> This patch adds debugfs capabilities to netback. There used to be a similar
> patch floating around for classic kernel, but it used procfs. It is based on a
> very similar blkback patch.
> It creates xen-netback/[vifname]/io_ring_q[queueno] files, reading them output
> various ring variables etc. Writing "kick" into it imitates an interrupt
> happened, it can be useful to check whether the ring is just stalled due to a
> missed interrupt.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied, but like others I consider those ifdefs hella ugly.

Provide stubs in an #else block, then you don't have to crap up the
main code.
