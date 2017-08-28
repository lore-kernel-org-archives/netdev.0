From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH iproute2 3/4] tc: m_ife: report about kernels default type
Date: Mon, 28 Aug 2017 18:18:27 -0400
Message-ID: <cc425722-f44f-4009-05af-3b5936c3cc65@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
 <20170828190738.26829-4-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:37781 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751215AbdH1WSa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:18:30 -0400
Received: by mail-io0-f193.google.com with SMTP id j99so1633827ioo.4
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:18:29 -0700 (PDT)
In-Reply-To: <20170828190738.26829-4-aring@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same comment as previous patch.

cheers,
jamal

On 17-08-28 03:07 PM, Alexander Aring wrote:
> This patch will report about if the ethertype for IFE is not specified
> that the default IFE type is used.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>
> ---
>   tc/m_ife.c | 2 ++
>   1 file changed, 2 insertions(+)
> 
> diff --git a/tc/m_ife.c b/tc/m_ife.c
> index 7b57130e..5633ab90 100644
> --- a/tc/m_ife.c
> +++ b/tc/m_ife.c
> @@ -189,6 +189,8 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
>   		addattr_l(n, MAX_MSG, TCA_IFE_DMAC, dbuf, ETH_ALEN);
>   	if (user_type)
>   		addattr_l(n, MAX_MSG, TCA_IFE_TYPE, &ife_type, 2);
> +	else
> +		fprintf(stderr, "IFE type 0x%04X\n", ETH_P_IFE);
>   	if (saddr)
>   		addattr_l(n, MAX_MSG, TCA_IFE_SMAC, sbuf, ETH_ALEN);
>   
> 
