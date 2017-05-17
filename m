From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 06/10] net: sched: introduce helpers to work
 with filter chains
Date: Wed, 17 May 2017 08:18:00 -0400
Message-ID: <ae02e4e8-3047-cd42-9c53-a2a38f8c28df@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-7-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34061 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEQMSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:18:03 -0400
Received: by mail-io0-f193.google.com with SMTP id 12so1228846iol.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:18:03 -0700 (PDT)
In-Reply-To: <20170517090803.4461-7-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:07 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Introduce struct tcf_chain object and set of helpers around it. Wraps up
> insertion, deletion and search in the filter chain.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---

[..]
> +
> +static void
> +tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
> +			       struct tcf_proto __rcu **p_filter_chain)
> +

What are the rules for this? Common coding style is:
static void tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
                                            struct tcf_proto ..

I am sure that struct tcf_proto __rcu **p_filter_chain would
probably hit boundary of 80 chars - but it would look cleaner
to be consistent.

Otherwise:
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
