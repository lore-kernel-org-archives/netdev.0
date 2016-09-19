From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Mon, 19 Sep 2016 14:17:31 -0700
Message-ID: <9d2f75e6-0161-aa25-e362-ad7267ee2251@hpe.com>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
 <1474236233-28511-17-git-send-email-ncardwell@google.com>
 <20160919135734.04ab5172@xeon-e3>
 <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hpe.com ([15.241.48.72]:51931 "EHLO
        g9t5008.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932124AbcISVRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:17:33 -0400
In-Reply-To: <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2016 02:10 PM, Eric Dumazet wrote:
> On Mon, Sep 19, 2016 at 1:57 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>
>> Looks good, but could I suggest a simple optimization.
>> All these parameters are immutable in the version of BBR you are submitting.
>> Why not make the values const? And eliminate the always true long-term bw estimate
>> variable?
>>
>
> We could do that.
>
> We used to have variables (aka module params) while BBR was cooking in
> our kernels ;)

Are there better than epsilon odds of someone perhaps wanting to poke 
those values as it gets exposure beyond Google?

happy benchmarking,

rick jones
