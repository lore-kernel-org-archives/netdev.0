From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 13:45:09 +0300
Message-ID: <54DDD5B5.2050605@cogentembedded.com>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com> <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>, netdev@vger.kernel.org,
	mst@redhat.com, jasowang@redhat.com, viro@zeniv.linux.org.uk,
	davem@davemloft.net, jonathon.reinhart@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:62557 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbbBMKpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 05:45:12 -0500
Received: by mail-lb0-f174.google.com with SMTP id z11so14737924lbi.5
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 02:45:10 -0800 (PST)
In-Reply-To: <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2015 9:19 AM, Zhu Yanjun wrote:

> The default speed of normal nic is 1000M while the default speed
> of tun is 10M. Now the default speed of tun is changed to 1000M.
> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
> The command "ethtool -s tun0 speed 10/100/1000" can configure the
> speed of tun dynamically.

> CC: Michael S. Tsirkin <mst@redhat.com>
> CC: Jason Wang <jasowang@redhat.com>
> CC: Al Viro <viro@zeniv.linux.org.uk>
> Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Reviewed-by: Jonathon Reinhart <jonathon.reinhart@gmail.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

[...]

> diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> index 50ae243..78a09a7 100644
> --- a/include/uapi/linux/if_tun.h
> +++ b/include/uapi/linux/if_tun.h
> @@ -66,6 +66,11 @@
>   #define IFF_PERSIST	0x0800
>   #define IFF_NOFILTER	0x1000
>
> +/*add speed control, default 1000M*/

    Please do add spaces after /* and before */.

> +#define TUN_CTRL_SPD_10         0x0020
> +#define TUN_CTRL_SPD_100        0x0040
> +#define TUN_CTRL_SPD_1000       0x0080
> +
>   /* Socket options */
>   #define TUN_TX_TIMESTAMP 1

WBR, Sergei
