From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 1/2] bpf: Allow CGROUP_SKB eBPF program to
 access sk_buff
Date: Tue, 06 Jun 2017 18:40:38 +0200
Message-ID: <5936DB06.5070601@iogearbox.net>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com> <59369A30.1060301@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>, ast@fb.com
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55962 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdFFQkl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 12:40:41 -0400
In-Reply-To: <59369A30.1060301@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2017 02:04 PM, Daniel Borkmann wrote:
> On 06/01/2017 03:15 AM, Chenbo Feng wrote:
>> From: Chenbo Feng <fengc@google.com>
>>
>> This allows cgroup eBPF program to classify packet based on their
>> protocol or other detail information. Currently program need
>> CAP_NET_ADMIN privilege to attach a cgroup eBPF program, and A
>> process with CAP_NET_ADMIN can already see all packets on the system,
>> for example, by creating an iptables rules that causes the packet to
>> be passed to userspace via NFLOG.
>>
>> Signed-off-by: Chenbo Feng <fengc@google.com>
>
> Sorry, but I am puzzled what above change log has to do with the
> below diff?! Back then we decided not to add BPF_PROG_TYPE_CGROUP_SKB
> to may_access_skb(), since one can already use bpf_skb_load_bytes()
> helper to access pkt data, which is a much more flexible interface.
> Mind to elaborate why you cannot use bpf_skb_load_bytes() instead?

See my other email [1], this one is also problematic wrt SKF_LL_OFF.

   [1] http://patchwork.ozlabs.org/patch/771946/
