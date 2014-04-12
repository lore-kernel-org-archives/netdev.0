From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: xen-netfront: fix array initialization
 bug
Date: Sat, 12 Apr 2014 16:51:52 -0400 (EDT)
Message-ID: <20140412.165152.1877473530496221304.davem@davemloft.net>
References: <1397296540-3007-1-git-send-email-v.maffione@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, xen-devel@lists.xenproject.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: v.maffione@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397296540-3007-1-git-send-email-v.maffione@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincenzo Maffione <v.maffione@gmail.com>
Date: Sat, 12 Apr 2014 11:55:40 +0200

> This patch fixes the initialization of an array used in the TX
> datapath that was mistakenly initialized together with the
> RX datapath arrays. An out of range array access could happen
> when RX and TX rings had different sizes.
> 
> Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>

Good catch, applied, thanks.
