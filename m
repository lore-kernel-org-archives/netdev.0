From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net 1/2] net sched actions: fix access to uninitialized
 data
Date: Tue, 18 Apr 2017 08:51:39 -0400
Message-ID: <3d6dfd6c-821a-8569-abb2-8746f49c03f9@mojatatu.com>
References: <20170418101322.27666-1-w.bumiller@proxmox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Wolfgang Bumiller <w.bumiller@proxmox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36474 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752125AbdDRMvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 08:51:42 -0400
Received: by mail-io0-f196.google.com with SMTP id x86so32808480ioe.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 05:51:42 -0700 (PDT)
In-Reply-To: <20170418101322.27666-1-w.bumiller@proxmox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 06:13 AM, Wolfgang Bumiller wrote:
> Signed-off-by: Wolfgang Bumiller <w.bumiller@proxmox.com>
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
> (same as v1)
>
>  net/sched/act_api.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index b70aa57319ea..8cc883c063f0 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -604,7 +604,7 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
>  	if (err < 0)
>  		goto err_mod;
>
> -	if (tb[TCA_ACT_COOKIE]) {
> +	if (name == NULL && tb[TCA_ACT_COOKIE]) {
>  		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
>
>  		if (cklen > TC_COOKIE_MAX_SIZE) {
>

This one looks good.

cheers,
jamal
