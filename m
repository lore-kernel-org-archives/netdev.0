From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 net-next v2] bpf: add support for generic xdp
Date: Mon, 01 May 2017 19:33:47 +0200
Message-ID: <5907717B.3060608@iogearbox.net>
References: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net> <20170501092915.5c19395c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org, quentin.monnet@6wind.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50008 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750722AbdEARdy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 13:33:54 -0400
In-Reply-To: <20170501092915.5c19395c@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ +Quentin ]

On 05/01/2017 06:29 PM, Stephen Hemminger wrote:
> On Fri, 28 Apr 2017 15:44:29 +0200
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> Follow-up to commit c7272ca72009 ("bpf: add initial support for
>> attaching xdp progs") to also support generic XDP. This adds an
>> indicator for loaded generic XDP programs when programs are loaded
>> as shown in c7272ca72009, but the driver still lacks native XDP
>> support.
>>
>>    # ip link
>>    [...]
>>    3: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric qdisc [...]
>>        link/ether 0c:c4:7a:03:f9:25 brd ff:ff:ff:ff:ff:ff
>>    [...]
>>
>> In case the driver does support native XDP, but the user wants
>> to load the program as generic XDP (e.g. for testing purposes),
>> then this can be done with the same semantics as in c7272ca72009,
>> but with 'xdpgeneric' instead of 'xdp' command for loading:
>>
>>    # ip -force link set dev eno1 xdpgeneric obj xdp.o
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Applied, thanks for remembering to update man page.

No problem, thanks!

> Does bash-completion need update?

Yeah, so far there's only a bash completion for the tc tool
in the tree, but nothing else. Is there anything in the works
for covering other tools, Quentin?

Thanks again,
Daniel
