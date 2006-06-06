From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unsigned long => __be32 in icmp_redirect()
Date: Mon, 05 Jun 2006 21:18:03 -0700 (PDT)
Message-ID: <20060605.211803.115910746.davem@davemloft.net>
References: <20060527212925.GC7267@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34469
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932072AbWFFESY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:18:24 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060527212925.GC7267@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 28 May 2006 01:29:25 +0400

> ip_rt_redirect() expects __be32 as second arg, so...
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I'm going to cure this by simple killing the 'ip' variable
altogether.  It is assigned once, to iph->daddr, and used
once, as an argument.  So just pass iph->daddr directly.

Thanks for finding this.
