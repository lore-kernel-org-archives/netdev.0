From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/1]x25: fix for spinlock recurse and spinlock lockup
 with timer handler in x25
Date: Fri, 28 Apr 2006 12:00:33 -0700 (PDT)
Message-ID: <20060428.120033.86347954.davem@davemloft.net>
References: <1145509403.16180.10.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, eis@baty.hanse.de,
	linux-x25@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18381
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751119AbWD1TBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:01:24 -0400
To: spereira@tusc.com.au
In-Reply-To: <1145509403.16180.10.camel@spereira05.tusc.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaun Pereira <spereira@tusc.com.au>
Date: Thu, 20 Apr 2006 15:03:23 +1000

> From: spereira@tusc.com.au
> 
> When the sk_timer function x25_heartbeat_expiry() is called by the kernel
> in a running/terminating process, spinlock-recursion and spinlock-lockup
> locks up the kernel. 
> This has happened with testing on some distro's and the patch below fixed it.
> 
> Signed-off-by:Shaun Pereira <spereira@tusc.com.au>

Applied, thanks.
