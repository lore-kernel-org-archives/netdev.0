From: David Miller <davem@davemloft.net>
Subject: Re: [v4 Patch 2/3] bridge: make bridge support netpoll
Date: Tue, 27 Apr 2010 15:23:34 -0700 (PDT)
Message-ID: <20100427.152334.24596525.davem@davemloft.net>
References: <20100427075937.4908.18468.sendpatchset@localhost.localdomain>
	<20100427075952.4908.60515.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	mpm@selenic.com, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100427075952.4908.60515.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Tue, 27 Apr 2010 03:55:56 -0400

> +		if (p->dev->priv_flags & IFF_DISABLE_NETPOLL
> +				|| !p->dev->netdev_ops->ndo_poll_controller)

"||" goes on first line, and indentation on second line is incorrect.
See my comments from patch #1.
