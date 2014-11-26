From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Remove BUGs on paged skb data which
 crosses a page boundary
Date: Wed, 26 Nov 2014 12:28:12 -0500 (EST)
Message-ID: <20141126.122812.223757363894961994.davem@davemloft.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416968904-70874-1-git-send-email-seth.forshee@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Can I get some Xen developer reviews?

Thanks.
