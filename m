From: Roi Dayan <roid@mellanox.com>
Subject: Re: [PATCH net-next] net/sched: Export tc_tunnel_key so its UAPI
 accessible
Date: Sun, 27 Nov 2016 12:14:30 +0200
Message-ID: <583AB206.8060208@mellanox.com>
References: <1480241233-50097-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roid@mellanox.com>, <netdev@vger.kernel.org>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0073.outbound.protection.outlook.com ([104.47.2.73]:43611
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753800AbcK0MWl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 07:22:41 -0500
In-Reply-To: <1480241233-50097-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My mistake. this should be targeted for net. I'm sending a patch over 
net branch.

Thanks,
Roi


On 27/11/2016 12:07, Roi Dayan wrote:
> Export tc_tunnel_key so it can be used from user space.
>
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> Reviewed-by: Amir Vadai <amir@vadai.me>
> ---
>   include/uapi/linux/tc_act/Kbuild | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
> index e3969bd..9611c7b 100644
> --- a/include/uapi/linux/tc_act/Kbuild
> +++ b/include/uapi/linux/tc_act/Kbuild
> @@ -11,3 +11,4 @@ header-y += tc_vlan.h
>   header-y += tc_bpf.h
>   header-y += tc_connmark.h
>   header-y += tc_ife.h
> +header-y += tc_tunnel_key.h
