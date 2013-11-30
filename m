From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: Fix pull size in
 checksum_setup_ip*
Date: Sat, 30 Nov 2013 16:10:00 -0500 (EST)
Message-ID: <20131130.161000.1050565138363035368.davem@davemloft.net>
References: <1385751407-9365-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jonathan.davies@citrix.com,
	paul.durrant@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385751407-9365-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Fri, 29 Nov 2013 18:56:47 +0000

> Before checksum setup we need to make sure we have enough data in linear
> buffer, so we do a pull if not. The calculation of the required data counts
> with skb->network_header, which is the headroom size actually. This is not
> necessary, and can cause unreasonable pulling. I've also removed
> MAX_IPOPTLEN, as we only need the base header at that point.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

The net-next tree is no open, therefore it is not appropriate to submit
patches targetting to that tree at this time.

I will make an explicit announcement on netdev when I have openned
the net-next tree, so it will be clear exactly when you can submit
patches targetting that tree again.

Thank you.
