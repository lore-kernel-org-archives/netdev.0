From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] 8021q: vlan device is lockless do not
 transfer real_num_{tx|rx}_queues
Date: Sun, 28 Nov 2010 10:48:33 -0800 (PST)
Message-ID: <20101128.104833.112592379.davem@davemloft.net>
References: <20101124231450.3158.67194.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36556
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753907Ab0K1SsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 13:48:07 -0500
In-Reply-To: <20101124231450.3158.67194.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Wed, 24 Nov 2010 15:14:50 -0800

> Now that the vlan device is lockless and single queue do not
> transfer the real num queues. This is causing a BUG_ON to occur.
> 
> kernel BUG at net/8021q/vlan.c:345!
> Call Trace:
> [<ffffffff813fd6e8>] ? fib_rules_event+0x28/0x1b0
> [<ffffffff814ad2b5>] notifier_call_chain+0x55/0x80
> [<ffffffff81089156>] raw_notifier_call_chain+0x16/0x20
> [<ffffffff813e5af7>] call_netdevice_notifiers+0x37/0x70
> [<ffffffff813e6756>] netdev_features_change+0x16/0x20
> [<ffffffffa02995be>] ixgbe_fcoe_enable+0xae/0x100 [ixgbe]
> [<ffffffffa01da06a>] vlan_dev_fcoe_enable+0x2a/0x30 [8021q]
> [<ffffffffa02d08c3>] fcoe_create+0x163/0x630 [fcoe]
> [<ffffffff811244d5>] ? mmap_region+0x255/0x5a0
> [<ffffffff81080ef0>] param_attr_store+0x50/0x80
> [<ffffffff810809b6>] module_attr_store+0x26/0x30
> [<ffffffff811b9db2>] sysfs_write_file+0xf2/0x180
> [<ffffffff8114fc88>] vfs_write+0xc8/0x190
> [<ffffffff81150621>] sys_write+0x51/0x90
> [<ffffffff8100c0b2>] system_call_fastpath+0x16/0x1b
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
