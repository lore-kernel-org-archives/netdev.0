From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 5/6] sched: add missing curly braces in else
 branch in tc_ctl_tfilter
Date: Thu, 9 Feb 2017 13:27:10 -0500
Message-ID: <0158ade7-fdf9-8aaf-4573-deb844a0cb92@mojatatu.com>
References: <1486647540-14656-1-git-send-email-jiri@resnulli.us>
 <1486647540-14656-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36383 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdBIS1M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 13:27:12 -0500
Received: by mail-io0-f193.google.com with SMTP id q20so2911363ioi.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:27:12 -0800 (PST)
In-Reply-To: <1486647540-14656-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-09 08:38 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Curly braces need to be there, for stylistic reasons.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/sched/cls_api.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index f44378c..48864ad 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -315,8 +315,9 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
>  					err = -EINVAL;
>  					goto errout;
>  				}
> -			} else
> +			} else {
>  				tp = NULL;
> +			}
>  			break;
>  		}
>  	}
>

Jiri, shall we engage in a long discussion about which rule says that
you can put braces around one line branching? ;->

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
