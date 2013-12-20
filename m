From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch ipsec-next 4/5] xfrm: fix checkpatch error
Date: Fri, 20 Dec 2013 17:50:12 +0400
Message-ID: <52B44B14.5000906@cogentembedded.com>
References: <1387536577-11480-1-git-send-email-chenweilong@huawei.com> <1387536577-11480-5-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:39159 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932389Ab3LTNuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 08:50:04 -0500
Received: by mail-la0-f43.google.com with SMTP id n7so1132744lam.30
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 05:50:02 -0800 (PST)
In-Reply-To: <1387536577-11480-5-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 20-12-2013 14:49, Chen Weilong wrote:

> From: Weilong Chen <chenweilong@huawei.com>

> Fix that "else should follow close brace '}'".

> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> ---
>   net/xfrm/xfrm_policy.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index fbc72b4..0ed4770 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -1316,8 +1316,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
>   			error = (x->km.state == XFRM_STATE_ERROR ?
>   				 -EINVAL : -EAGAIN);
>   			xfrm_state_put(x);
> -		}
> -		else if (error == -ESRCH)
> +		} else if (error == -ESRCH)
>   			error = -EAGAIN;

    According to CodingStyle, both branches of *if* should have {}, if one has 
it. You may as well fix this.

WBR, Sergei
