From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v4 08/10] net: sched: introduce multichain
 support for filters
Date: Wed, 17 May 2017 08:27:37 -0400
Message-ID: <832a56d9-8846-a7d3-5ab8-d0f3713bef94@mojatatu.com>
References: <20170517090803.4461-1-jiri@resnulli.us>
 <20170517090803.4461-9-jiri@resnulli.us>
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
Received: from mail-io0-f196.google.com ([209.85.223.196]:33740 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751607AbdEQM1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 08:27:40 -0400
Received: by mail-io0-f196.google.com with SMTP id m4so1260748ioe.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 05:27:39 -0700 (PDT)
In-Reply-To: <20170517090803.4461-9-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-17 05:08 AM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Instead of having only one filter per block, introduce a list of chains
> for every block. Create chain 0 by default. UAPI is extended so the user
> can specify which chain he wants to change. If the new attribute is not
> specified, chain 0 is used. That allows to maintain backward
> compatibility. If chain does not exist and user wants to manipulate with
> it, new chain is created with specified index. Also, when last filter is
> removed from the chain, the chain is destroyed.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
