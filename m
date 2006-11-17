From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2][XFRM]: Sub-policies beautification
Date: Fri, 17 Nov 2006 17:42:53 +0100
Message-ID: <20061117164253.GE8693@postel.suug.ch>
References: <1163772616.5107.40.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:8588 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933717AbWKQQmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 11:42:32 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1163772616.5107.40.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-11-17 09:10
> First one
> 
> cheers,
> jamal

> [XFRM]: Make copy_to_user_policy_type take a type
> Make copy_to_user_policy_type take a type instead a policy and
> fix its users to pass the type
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> ---
> commit 5e6a47d1e7baabd38cca9d01f3d78ae1319db535
> tree cb4b19b38076cdf545a591ae9d5d6ecd8849c0bc
> parent c3d793454ab2a36c2d618d226d7de975ab9b7570
> author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 17 Nov 2006 08:52:26 -0500
> committer Jamal Hadi Salim <hadi@jzny2.(none)> Fri, 17 Nov 2006 08:52:26 -0500
> 
>  net/xfrm/xfrm_user.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index c4cde57..3c34385 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -1082,12 +1082,12 @@ static inline int copy_to_user_sec_ctx(s
>  }
>  
>  #ifdef CONFIG_XFRM_SUB_POLICY
> -static int copy_to_user_policy_type(struct xfrm_policy *xp, struct sk_buff *skb)
> +static int copy_to_user_policy_type(__u8 type, struct sk_buff *skb)

Could you maybe use u8 instead of the  userspace alternative __u8?

The other patches look good.

