From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf: introduce bpf_clone_redirect() helper
Date: Thu, 04 Jun 2015 08:06:48 -0700
Message-ID: <55706988.6010406@plumgrid.com>
References: <1433286194-5246-1-git-send-email-ast@plumgrid.com>	<20150603.201727.1848194519762843477.davem@davemloft.net> <CAJ3xEMgqw3Kj5SdBDsyr18z_n4n6BeOJLcjK2iMnaqMwuJ+tEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35761 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbbFDPGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:06:51 -0400
Received: by pdbnf5 with SMTP id nf5so32836111pdb.2
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:06:51 -0700 (PDT)
In-Reply-To: <CAJ3xEMgqw3Kj5SdBDsyr18z_n4n6BeOJLcjK2iMnaqMwuJ+tEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/3/15 11:45 PM, Or Gerlitz wrote:
> On Thu, Jun 4, 2015 at 6:17 AM, David Miller <davem@davemloft.net> wrote:
>> From: Alexei Starovoitov <ast@plumgrid.com>
>> Date: Tue,  2 Jun 2015 16:03:14 -0700
>>
>>> Allow eBPF programs attached to classifier/actions to call
>>> bpf_clone_redirect(skb, ifindex, flags) helper which will
>>> mirror or redirect the packet by dynamic ifindex selection
>>> from within the program to a target device either at ingress
>>> or at egress. Can be used for various scenarios, for example,
>>> to load balance skbs into veths, split parts of the traffic
>>> to local taps, etc.
>>>
>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>>
>> Applied, thanks.
>
> build fails on my setup...
>
> CC [M]  net/core/pktgen.o
> net/core/filter.c: In function 'bpf_clone_redirect':
> net/core/filter.c:1429: error: 'struct sk_buff' has no member named 'tc_verd'
>
> you use skb->tc_verd but this code snippest goes along without being
> dependent on CONFIG_NET_CLS_ACT

sorry. my bad. will get it fixed asap.
