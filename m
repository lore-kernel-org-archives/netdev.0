From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: cleanup A/X name usage
Date: Tue, 10 Jun 2014 09:29:00 +0200
Message-ID: <5396B3BC.30504@redhat.com>
References: <1402091166-5206-1-git-send-email-ast@plumgrid.com> <5394C5CB.7050000@redhat.com> <CAMEtUux+sj7o9=57JAaHvGJXJmfuyRKb+dFL_3ZdkmAoHy9XzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58238 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936237AbaFJH3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 03:29:07 -0400
In-Reply-To: <CAMEtUux+sj7o9=57JAaHvGJXJmfuyRKb+dFL_3ZdkmAoHy9XzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2014 09:25 PM, Alexei Starovoitov wrote:
...
> Point taken. Will do more thorough documentation patch to
> explain eBPF instruction set a bit better. Mainly to clarify encoding.
> eBPF tried to be as close as possible to classic BPF, since I thought
> it will make it easier to understand. That's why I reused A/X in names
> and bits in opcode encoding.
> In classic, A is accumulator and X is indeX. In eBPF I thought
> calling destination register 'a_reg' made sense, since it would
> indicate that this 'a_reg' is a register that is used as 'accumulator'
> in the instruction. Like in "bpf_add R2, 5", R2 is Accumulator.
> In "bpf_add R2, R3", R2  is Accumulator and R3 is indeX
> and BPF_X bit in opcode indicates whether 'x_reg' field of the
> instruction is used. Unfortunately that decision caused the whole
> A/X naming confusion, that this patch is addressing.
> src_reg and dst_reg are indeed better names.

I think both naming conventions (before/after) are fine, imho.
