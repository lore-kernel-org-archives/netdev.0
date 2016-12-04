From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [Patch net-next] act_mirred: fix a typo in get_dev
Date: Sun, 4 Dec 2016 15:12:45 +0200
Message-ID: <d2208187-5ba3-1819-dd81-3b56a6a1ac4c@mellanox.com>
References: <1480790161-8097-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:22754
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751201AbcLEDSd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 22:18:33 -0500
In-Reply-To: <1480790161-8097-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/3/2016 8:36 PM, Cong Wang wrote:
> Cc: Hadar Hen Zion <hadarh@mellanox.com>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>   net/sched/act_mirred.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index bb09ba3..2d9fa6e 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -321,7 +321,7 @@ static int tcf_mirred_device(const struct tc_action *a, struct net *net,
>   	int ifindex = tcf_mirred_ifindex(a);
>   
>   	*mirred_dev = __dev_get_by_index(net, ifindex);
> -	if (!mirred_dev)
> +	if (!*mirred_dev)
>   		return -EINVAL;
>   	return 0;
>   }
Thank you for this fix! good catch.
I know it's already applied.

Hadar
