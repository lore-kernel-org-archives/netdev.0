From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [patch net-next v3 2/2] net: core: introduce mini_Qdisc and eliminate
 usage of tp->q for clsact fastpath
Date: Wed, 01 Nov 2017 11:25:02 +0100
Message-ID: <59F9A0FE.2040608@iogearbox.net>
References: <20171031151222.5021-1-jiri@resnulli.us> <20171031151222.5021-3-jiri@resnulli.us> <20171101021248.624bvt5jcqr37w5e@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33742 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdKAKZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 06:25:07 -0400
In-Reply-To: <20171101021248.624bvt5jcqr37w5e@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 03:12 AM, Alexei Starovoitov wrote:
> On Tue, Oct 31, 2017 at 04:12:22PM +0100, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
[...]
> I don't think it's great, but I don't have any suggestions on
> how to avoid it, so I'm not objecting. Just disappointed that
> you keep adding stuff to tc and messing with sw fast path only to
> make parity with some obscure hw feature.

tc became a sink for that over time.

> If it keeps going like this we'd need to come up with some new fast
> hook for clsbpf in ingress/egress paths. We use it for
> every packet, so extra loads are not great.
> I guess they should be cache hits, but will take extra cache line.
> All of the bugs in tc logic recently are not comforting either.

+1
