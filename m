From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i825xx: fix paging fault on znet_probe()
Date: Tue, 04 Sep 2012 15:13:06 -0400 (EDT)
Message-ID: <20120904.151306.1766477429185359707.davem@davemloft.net>
References: <20120902072546.GA20290@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120902072546.GA20290@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fengguang Wu <fengguang.wu@intel.com>
Date: Sun, 2 Sep 2012 15:25:46 +0800

> In znet_probe(), strncmp() may access beyond 0x100000 and
> trigger the below oops in kvm.  Fix it by limiting the loop
> under 0x100000-8. I suspect the limit could be further decreased
> to 0x100000-sizeof(struct netidblk), however no datasheet at hand..
 ...
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

This also makes the code actually match the description in the comment
above the loop :-)

Applied, thanks.
