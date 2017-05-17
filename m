From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 02/10] net: sched: introduce tcf block
 infractructure
Date: Wed, 17 May 2017 08:12:00 -0400
Message-ID: <91a26914-9e18-7358-7a57-ac354dfe0eb9@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-3-jiri@resnulli.us>
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
Received: from mail-io0-f196.google.com ([209.85.223.196]:34569 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdEQMMD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:12:03 -0400
Received: by mail-io0-f196.google.com with SMTP id 12so1213960iol.1
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:12:03 -0700 (PDT)
In-Reply-To: <20170517090803.4461-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:07 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Currently, the filter chains are direcly put into the private structures
> of qdiscs. In order to be able to have multiple chains per qdisc and to
> allow filter chains sharing among qdiscs, there is a need for common
> object that would hold the chains. This introduces such object and calls
> it "tcf_block".
>
> Helpers to get and put the blocks are provided to be called from
> individual qdisc code. Also, the original filter_list pointers are left
> in qdisc privs to allow the entry into tcf_block processing without any
> added overhead of possible multiple pointer dereference on fast path.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
