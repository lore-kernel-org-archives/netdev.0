From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Tue, 27 Sep 2016 12:39:34 +0200
Message-ID: <57EA4C66.8070907@iogearbox.net>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>        <20160927.015606.437705429903770747.davem@davemloft.net> <20160927110711.12555f4e@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50978 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753244AbcI0Kji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 06:39:38 -0400
In-Reply-To: <20160927110711.12555f4e@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2016 10:07 AM, Shmulik Ladkani wrote:
> Hi David,
>
> On Tue, 27 Sep 2016 01:56:06 -0400 (EDT), davem@davemloft.net wrote:
>> The discussion on this patch has ventured off into what to do about
>> recursion.
>>
>> But it unclear to me where this specific patch, and this series,
>> stands right now.  Someone please clear this up for me.
>
> Status:
>   - Series adds "ingress redirect/mirror" support
>   - Positive feedback for the feature
>   - So far no comments regarding code itself
>   - Questions raised regarding "recursion handling"
>     Expressed that existing mirred code (i.e egress redirect) is *already*
>     loop-unsafe (and also, some non-tc netdev constructs, as exampled by
>     others).
>     Discussion then wandered to "recursion handling".

Any reason why dev_forward_skb() is not preferred over direct
netif_receive_skb() you're using? It would, for example, implicitly
assure that pkt_type is always PACKET_HOST, etc.

Thanks,
Daniel
