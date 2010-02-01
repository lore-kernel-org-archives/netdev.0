From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net: export TCP send buffer size via netlink
Date: Mon, 01 Feb 2010 01:58:12 -0800 (PST)
Message-ID: <20100201.015812.21220633.davem@davemloft.net>
References: <20100201080256.4084.30962.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100201080256.4084.30962.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 1 Feb 2010 02:59:32 -0500

> 
> Currently, we can only get TCP send buffer size by
> getsockopt (SO_SNDBUF or TCP_INFO), this is not enough
> for the tools like netstat or ss to read.
> 
> Show TCP send buffer size via netlink NETLINK_INET_DIAG.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David Miller <davem@davemloft.net>

You can't change the layout of struct tcp_info, it's
hard coded into applications.
