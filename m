From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 06/10] net: sched: introduce helpers to work
 with filter chains
Date: Wed, 17 May 2017 14:25:28 +0200
Message-ID: <20170517122528.GA9557@nanopsycho>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-7-jiri@resnulli.us>
 <ae02e4e8-3047-cd42-9c53-a2a38f8c28df@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, stephen@networkplumber.org,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35393 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753015AbdEQMZc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:25:32 -0400
Received: by mail-wr0-f194.google.com with SMTP id g12so1567257wrg.2
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:25:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ae02e4e8-3047-cd42-9c53-a2a38f8c28df@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 17, 2017 at 02:18:00PM CEST, jhs@mojatatu.com wrote:
>On 17-05-17 05:07 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> Introduce struct tcf_chain object and set of helpers around it. Wraps up
>> insertion, deletion and search in the filter chain.
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>
>[..]
>> +
>> +static void
>> +tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
>> +			       struct tcf_proto __rcu **p_filter_chain)
>> +
>
>What are the rules for this? Common coding style is:
>static void tcf_chain_filter_chain_ptr_set(struct tcf_chain *chain,
>                                           struct tcf_proto ..

When this would not fit 80 cols (this case), you need to wrap the
text in front of the function name. That is exacly what I did.


>
>I am sure that struct tcf_proto __rcu **p_filter_chain would
>probably hit boundary of 80 chars - but it would look cleaner
>to be consistent.
>
>Otherwise:
>Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>cheers,
>jamal
>
