From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2, kernel 3.2.1] RTNETLINK adjusting values of
 min_ifinfo_dump_size
Date: Thu, 26 Jan 2012 16:37:25 -0500 (EST)
Message-ID: <20120126.163725.208323115932061885.davem@davemloft.net>
References: <3280801.2791327611666778.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3280801.2791327611666778.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Thu, 26 Jan 2012 22:01:06 +0100 (CET)

> From: Stefan Gula <steweg@gmail.com>
> 
> Setting link parameters on a netdevice changes the value
> of if_nlmsg_size(), therefore it is necessary to recalculate
> min_ifinfo_dump_size.
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>

Applied, but:

> +	min_ifinfo_dump_size = max_t(u16, if_nlmsg_size(dev),
> +					min_ifinfo_dump_size);
> +

The second line is not properly indented, the first non-space
character should line up with the first column after the
openning parenthesis on the previous line.

I fixed this up, but really this was a lot of tooth pulling to
get you to post this patch correctly.  You cannot consume this
much maintainer and reviewer resources in the future.
