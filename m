From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: exit probe with unknown register layout
Date: Mon, 17 Mar 2014 16:05:31 -0400 (EDT)
Message-ID: <20140317.160531.2098314333892795669.davem@davemloft.net>
References: <201403150311.25173.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201403150311.25173.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 15 Mar 2014 03:11:24 +0300

> Exit the driver's probe() method when the register layout is unknown as the
> driver would cause kernel oops in this case anyway.
> 
> While at it, move the corresponding error message printout and convert it from
> pr_err() to dev_err().
> 
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied, thanks.
