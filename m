From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 2/9] ipv6: sr: add code base for control plane support of
 SR-IPv6
Date: Wed, 31 Aug 2016 10:11:52 -0700
Message-ID: <20160831101152.75953b3c@xeon-e3>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
        <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34091 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161189AbcHaRLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:11:43 -0400
Received: by mail-pf0-f179.google.com with SMTP id p64so21459524pfb.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:11:43 -0700 (PDT)
In-Reply-To: <1472226767-9904-3-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2016 17:52:40 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +static struct genl_ops seg6_genl_ops[] = {
> +	{
> +		.cmd	= SEG6_CMD_SETHMAC,
> +		.doit	= seg6_genl_sethmac,
> +		.policy	= seg6_genl_policy,
> +		.flags	= GENL_ADMIN_PERM,
> +	},
> +	{
> +		.cmd	= SEG6_CMD_DUMPHMAC,
> +		.dumpit	= seg6_genl_dumphmac,
> +		.policy	= seg6_genl_policy,
> +		.flags	= GENL_ADMIN_PERM,
> +	},
> +	{
> +		.cmd	= SEG6_CMD_SET_TUNSRC,
> +		.doit	= seg6_genl_set_tunsrc,
> +		.policy	= seg6_genl_policy,
> +		.flags	= GENL_ADMIN_PERM,
> +	},
> +	{
> +		.cmd	= SEG6_CMD_GET_TUNSRC,
> +		.doit	= seg6_genl_get_tunsrc,
> +		.policy = seg6_genl_policy,
> +		.flags	= GENL_ADMIN_PERM,
> +	},
> +};
> +

Should also be const
