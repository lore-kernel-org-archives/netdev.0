From: David Miller <davem@davemloft.net>
Subject: Re: [v4 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Tue, 27 Apr 2010 15:22:36 -0700 (PDT)
Message-ID: <20100427.152236.73676344.davem@davemloft.net>
References: <20100427075937.4908.18468.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net, fubar@us.ibm.com
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100427075937.4908.18468.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amerigo Wang <amwang@redhat.com>
Date: Tue, 27 Apr 2010 03:55:41 -0400

> +	if (ndev->priv_flags & IFF_DISABLE_NETPOLL
> +			|| !ndev->netdev_ops->ndo_poll_controller) {

" ||" goes on first line, not second, and second line needs to be indented
properly so that "!ndev->..." matches up with "ndev->priv_flags ..." on
the previous line.
