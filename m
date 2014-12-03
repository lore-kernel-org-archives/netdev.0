From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Remove BUGs on paged skb data which
 crosses a page boundary
Date: Tue, 02 Dec 2014 19:25:30 -0800 (PST)
Message-ID: <20141202.192530.460426718376541462.davem@davemloft.net>
References: <1416968904-70874-1-git-send-email-seth.forshee@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, zoltan.kiss@linaro.org,
	eric.dumazet@gmail.com, stefan.bader@canonical.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: seth.forshee@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaLCDVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 22:21:09 -0500
In-Reply-To: <1416968904-70874-1-git-send-email-seth.forshee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Seth Forshee <seth.forshee@canonical.com>
Date: Tue, 25 Nov 2014 20:28:24 -0600

> These BUGs can be erroneously triggered by frags which refer to
> tail pages within a compound page. The data in these pages may
> overrun the hardware page while still being contained within the
> compound page, but since compound_order() evaluates to 0 for tail
> pages the assertion fails. The code already iterates through
> subsequent pages correctly in this scenario, so the BUGs are
> unnecessary and can be removed.
> 
> Fixes: f36c374782e4 ("xen/netfront: handle compound page fragments on transmit")
> Cc: <stable@vger.kernel.org> # 3.7+
> Signed-off-by: Seth Forshee <seth.forshee@canonical.com>

Applied, thanks.
