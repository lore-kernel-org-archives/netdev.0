From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netback: making the bandwidth limiter runtime
 settable
Date: Fri, 20 Mar 2015 12:55:28 -0400 (EDT)
Message-ID: <20150320.125528.1702067663910531304.davem@davemloft.net>
References: <1426759542-15948-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, imrep@amazon.de, aliguori@amazon.com
To: imrep.amz@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426759542-15948-1-git-send-email-imrep.amz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Imre Palik <imrep.amz@gmail.com>
Date: Thu, 19 Mar 2015 11:05:42 +0100

> From: "Palik, Imre" <imrep@amazon.de>
> 
> With the current netback, the bandwidth limiter's parameters are only
> settable during vif setup time.  This patch register a watch on them, and
> thus makes them runtime changeable.
> 
> When the watch fires, the timer is reset.  The timer's mutex is used for
> fencing the change.
> 
> Cc: Anthony Liguori <aliguori@amazon.com>
> Signed-off-by: Imre Palik <imrep@amazon.de>

Applied to net-next, thanks.
