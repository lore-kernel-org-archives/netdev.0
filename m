From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next] tc_vlan: fix type of tcfv_push_vid
Date: Mon, 24 Nov 2014 08:25:52 -0500
Message-ID: <547331E0.6030305@mojatatu.com>
References: <1416825026-4628-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33257 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbaKXNZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 08:25:56 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so1103031ieb.17
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 05:25:55 -0800 (PST)
In-Reply-To: <1416825026-4628-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/14 05:30, Jiri Pirko wrote:
> Should be u16. So fix it to kill the sparse warning.
>
> Fixes: c7e2b9689ef8136 "sched: introduce vlan action"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/net/tc_act/tc_vlan.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/net/tc_act/tc_vlan.h b/include/net/tc_act/tc_vlan.h
> index c809c1d..93b70ad 100644
> --- a/include/net/tc_act/tc_vlan.h
> +++ b/include/net/tc_act/tc_vlan.h
> @@ -18,7 +18,7 @@
>   struct tcf_vlan {
>   	struct tcf_common	common;
>   	int			tcfv_action;
> -	__be16			tcfv_push_vid;
> +	u16			tcfv_push_vid;
>   	__be16			tcfv_push_proto;


User space sends you this in be, no? I thought it was fine
the way it is. Isnt __be16 just an annotation?

cheers,
jamal
