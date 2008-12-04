From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] net: remove duplicated #include
Date: Thu, 04 Dec 2008 13:25:54 +0800
Message-ID: <493769E2.6020602@cn.fujitsu.com>
References: <20081204022650.GA5159@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jianjun Kong <jianjun@zeuux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56785 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752196AbYLDF0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 00:26:10 -0500
In-Reply-To: <20081204022650.GA5159@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jianjun Kong said the following on 2008-12-4 10:26:
> net: remove duplicated #include
> 
> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
> ---
>  net/socket.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/net/socket.c b/net/socket.c
> index 92764d8..e9d65ea 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -69,7 +69,6 @@
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/mutex.h>
> -#include <linux/thread_info.h>
>  #include <linux/wanrouter.h>
>  #include <linux/if_bridge.h>
>  #include <linux/if_frad.h>

This was fixed in net-next.

