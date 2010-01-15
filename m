From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/core/sock.c: quiet sparse noise
Date: Fri, 15 Jan 2010 01:09:16 -0800 (PST)
Message-ID: <20100115.010916.104760167.davem@davemloft.net>
References: <201001141721.45305.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756973Ab0AOJJK@vger.kernel.org>
In-Reply-To: <201001141721.45305.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Thu, 14 Jan 2010 17:21:45 -0700

> net/core/sock.c: quiet sparse noise
> 
> In sock_getsockopt the symbol 'lv' is declared as an
> unsigned int type, probably due to sizeof returning a
> size_t which is really an unsigned int.
> 
> This produces a sparse warning for SO_PEERNAME due to
> the sock->ops->getname() call:
> 
> warning: incorrect type in argument 3 (different signedness)
>    expected int *sockaddr_len
>    got unsigned int *<noident>
> 
> Quiet the warning my changing the type of 'lv' to an int.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied to net-next-2.6, thanks.
