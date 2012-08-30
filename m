From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/3] forcedeth: fix device lock-up for
 dual-port NICs
Date: Thu, 30 Aug 2012 13:05:26 -0400 (EDT)
Message-ID: <20120830.130526.863740770089967659.davem@davemloft.net>
References: <cover.1345864542.git.decot@googlers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com, joe@perches.com
To: decot@googlers.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345864542.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>
Date: Fri, 24 Aug 2012 20:22:50 -0700

> On a dual port MCP55 10de:0373 (rev a3) NIC with both ports connected,
> we identified a configuration that does freeze the whole NIC: having
> autoneg & TX pause turned on while one port is physically connected
> but interface is down (eg. eth1) eventually causes the whole NIC to
> freeze (eth1 and... eth0). This triggers TX timeouts on the UP
> interface and, more generally, an unreachable network.
> 
> In order to avoid the bug, all we have to do is make sure not to
> configure TX pause on the hardware while NIC is down. This is what the
> 2nd patch of the series does (details included).
> 
> And, in case the NIC is in a bad state at reboot (should not happen
> anymore thanks to patch above), third patch basically always makes
> sure to fix the NIC when module is loaded.
> 
> I could only test this with a MCP55 10de:0373 (rev a3) PCI device on a
> x86_64 host.

All applied to net-next, thanks.
