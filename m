From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch iproute2 v2 repost 1/3] tc_filter: add support for chain
 index
Date: Fri, 26 May 2017 21:48:05 +0200
Message-ID: <59288675.4040009@iogearbox.net>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172937.1391-1-jiri@resnulli.us> <20170522133315.3490fe0a@xeon-e3> <20170523134042.GC1829@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, dsa@cumulusnetworks.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        simon.horman@netronome.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34719 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940852AbdEZTsN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:48:13 -0400
In-Reply-To: <20170523134042.GC1829@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 03:40 PM, Jiri Pirko wrote:
> Mon, May 22, 2017 at 10:33:15PM CEST, stephen@networkplumber.org wrote:
[...]
>> Applied to net-next branch of iproute2
>
> Looks like you missed the uapi part:
>
>      CC       tc_filter.o
> tc_filter.c: In function ‘tc_filter_modify’:
> tc_filter.c:159:34: error: ‘TCA_CHAIN’ undeclared (first use in this function)
>     addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_index);
>                                    ^~~~~~~~~

Looks like still unresolved in the iproute2 -net-next branch ...
