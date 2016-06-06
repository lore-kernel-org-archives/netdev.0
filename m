From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [PATCH net 1/2] net: cls_u32: fix error code for invalid flags
Date: Mon, 06 Jun 2016 10:16:19 -0700
Message-ID: <5755AFE3.5070807@intel.com>
References: <1465226208-32097-1-git-send-email-jakub.kicinski@netronome.com> <1465226208-32097-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44165 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbcFFRQU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2016 13:16:20 -0400
In-Reply-To: <1465226208-32097-2-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/6/2016 8:16 AM, Jakub Kicinski wrote:
> 'err' variable is not set in this test, we would return whatever
> previous test set 'err' to.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Sridhar Samudrala <sridhar.samudrala@intel.com>

> ---
>   net/sched/cls_u32.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 079b43b3c5d2..b17e090f2fe1 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -863,7 +863,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
>   	if (tb[TCA_U32_FLAGS]) {
>   		flags = nla_get_u32(tb[TCA_U32_FLAGS]);
>   		if (!tc_flags_valid(flags))
> -			return err;
> +			return -EINVAL;
>   	}
>   
>   	n = (struct tc_u_knode *)*arg;
