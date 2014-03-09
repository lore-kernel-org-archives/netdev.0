From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: switch net_ns only if net is not init_net
Date: Sun, 09 Mar 2014 19:09:41 -0400 (EDT)
Message-ID: <20140309.190941.472588800498066811.davem@davemloft.net>
References: <5319A3C2.8080001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guz.fnst@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5319A3C2.8080001@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Date: Fri, 07 Mar 2014 18:47:30 +0800

> Many netlink users create netlink sock in the init_net, and the
> switching nes_ns(init_net-->net) is needless in this case. So here
> we add a pre-check to avoid this.
> 
> Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>

This check is more appropriately placed into sk_change_net() itself.
