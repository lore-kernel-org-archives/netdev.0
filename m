From: David Miller <davem@davemloft.net>
Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Fri, 03 Feb 2012 19:29:33 -0500 (EST)
Message-ID: <20120203.192933.510206531351047222.davem@davemloft.net>
References: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
	<10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Fri, 3 Feb 2012 15:24:21 +0100 (CET)

> From: Stefan Gula <steweg@gmail.com>
> 
> Adding new rtnetlink ops and command for getting more information about
> network devices, which are not able to fit inside predefined SKB structures
> (e.g. PAGE_SIZE limit). DEVDUMP command allows to call specific device driver
> code for complete handling this netlink message. Useful if devices needed to
> list some addition dynamic structures like hlists and doesn't require to have
> complete set of codes for it new PF families.
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>

This is not how we're going to fix this.  I already stated the desired
way to fix this, which is to make the existing dump request have a way
for the requestor to enable extended parts of the device dump.

This is just like netlink diag socket dumps, where the dump request
specifies what the user wants to see.

In this case we'd add a netlink attribute to the dump request which
is just a u32 bitmask or similar.

The Intel engineer who added the VF dump support said he would work on
this fix so why don't you just wait patiently for him to do the work?
