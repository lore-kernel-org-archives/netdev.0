From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: x25: fix one potential use-after-free issue
Date: Thu, 18 May 2017 10:06:08 -0400 (EDT)
Message-ID: <20170518.100608.733334484371439292.davem@davemloft.net>
References: <1494993907-22727-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, linux-x25@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiaolou4617@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494993907-22727-1-git-send-email-xiaolou4617@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: linzhang <xiaolou4617@gmail.com>
Date: Wed, 17 May 2017 12:05:07 +0800

> The function x25_init is not properly unregister related resources
> on error handler.It is will result in kernel oops if x25_init init
> failed, so add properly unregister call on error handler.
> 
> Also, i adjust the coding style and make x25_register_sysctl properly
> return failure.
> 
> Signed-off-by: linzhang <xiaolou4617@gmail.com>

Applied, thanks.
