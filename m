From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 02/29] netfilter: physdev: add missed blank
Date: Mon, 05 Sep 2016 10:43:17 -0700
Message-ID: <1473097397.1992.3.camel@perches.com>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
         <1473073124-5015-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0024.hostedemail.com ([216.40.44.24]:39796 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933832AbcIERnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 13:43:20 -0400
In-Reply-To: <1473073124-5015-3-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-05 at 12:58 +0200, Pablo Neira Ayuso wrote:
[]
> diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
[]
> @@ -107,8 +107,8 @@ static int physdev_mt_check(const struct xt_mtchk_param *par)
>  	     info->invert & XT_PHYSDEV_OP_BRIDGED) &&
>  	    par->hook_mask & ((1 << NF_INET_LOCAL_OUT) |
>  	    (1 << NF_INET_FORWARD) | (1 << NF_INET_POST_ROUTING))) {
> -		pr_info("using --physdev-out and --physdev-is-out are only"
> -			"supported in the FORWARD and POSTROUTING chains with"
> +		pr_info("using --physdev-out and --physdev-is-out are only "
> +			"supported in the FORWARD and POSTROUTING chains with "
>  			"bridged traffic.\n");
>  		if (par->hook_mask & (1 << NF_INET_LOCAL_OUT))
>  			return -EINVAL;

Perhaps it would be reasonable at some point to coalesce
all the string fragments.

Maybe using this could help:

$ git ls-files -- "net/netfilter/*.[ch]" | \
  xargs ./scripts/checkpatch.pl  -f --types=split_string --fix-inplace
