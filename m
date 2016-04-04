From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] cxgb4/cxgb4vf: Deprecate module parameter
 dflt_msg_enable
Date: Mon, 4 Apr 2016 15:43:09 +0300
Message-ID: <5702615D.6080905@cogentembedded.com>
References: <1459745604-8093-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36713 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbcDDMnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 08:43:12 -0400
Received: by mail-lb0-f180.google.com with SMTP id qe11so159110221lbc.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 05:43:11 -0700 (PDT)
In-Reply-To: <1459745604-8093-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/4/2016 7:53 AM, Hariprasad Shenai wrote:

> Message level can be set through ethtool, so deprecate module parameter
> which is used to set the same.
>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 3 ++-
>   drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 3 ++-
>   2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index d1e3f0997d6b..acefa35b7250 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -168,7 +168,8 @@ MODULE_PARM_DESC(force_init, "Forcibly become Master PF and initialize adapter,"
>   static int dflt_msg_enable = DFLT_MSG_ENABLE;
>
>   module_param(dflt_msg_enable, int, 0644);
> -MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T4 default message enable bitmap");
> +MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T4 default message enable bitmap,"

    Need space after the last comma...

> +		 "deprecated parameter");
>
>   /*
>    * The driver uses the best interrupt scheme available on a platform in the
> diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> index 1cc8a7a69457..730fec73d5a6 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
> @@ -74,7 +74,8 @@ static int dflt_msg_enable = DFLT_MSG_ENABLE;
>
>   module_param(dflt_msg_enable, int, 0644);
>   MODULE_PARM_DESC(dflt_msg_enable,
> -		 "default adapter ethtool message level bitmap");
> +		 "default adapter ethtool message level bitmap, "

    ... like here.

> +		 "deprecated parameter");
>
>   /*
>    * The driver uses the best interrupt scheme available on a platform in the

MBR, Sergei
