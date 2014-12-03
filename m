From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 6/6] net_sched: cls_cgroup: remove unnecessary
 if
Date: Wed, 03 Dec 2014 08:07:06 -0500
Message-ID: <547F0AFA.7090001@mojatatu.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:54953 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaLCNHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:07:08 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so13606203ieb.21
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 05:07:08 -0800 (PST)
In-Reply-To: <1417539636-12710-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/14 12:00, Jiri Pirko wrote:
> since head->handle == handle (checked before), just assign handle.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   net/sched/cls_cgroup.c | 6 +-----
>   1 file changed, 1 insertion(+), 5 deletions(-)
>
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index d61a801..dbee65e 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -117,11 +117,7 @@ static int cls_cgroup_change(struct net *net, struct sk_buff *in_skb,
>   		return -ENOBUFS;
>
>   	tcf_exts_init(&new->exts, TCA_CGROUP_ACT, TCA_CGROUP_POLICE);
> -	if (head)
> -		new->handle = head->handle;
> -	else
> -		new->handle = handle;
> -
> +	new->handle = handle;


Hrm. head could be NULL, no?

cheers,
jamal
