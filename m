From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] ebpf: add sched_act_type and map it to sk_filter's
 verifier ops
Date: Fri, 20 Mar 2015 14:11:58 -0700
Message-ID: <550C8D1E.6070502@plumgrid.com>
References: <cover.1426859241.git.daniel@iogearbox.net> <3f1f15c00b7dd9899035696eef924b23a008afc2.1426859241.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35900 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157AbbCTVMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:12:07 -0400
Received: by padcy3 with SMTP id cy3so120099244pad.3
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:12:07 -0700 (PDT)
In-Reply-To: <3f1f15c00b7dd9899035696eef924b23a008afc2.1426859241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15 7:11 AM, Daniel Borkmann wrote:
> In order to prepare eBPF support for tc action, we need to add
> sched_act_type, so that the eBPF verifier is aware of what helper
> function act_bpf may use, that it can load skb data and read out
> currently available skb fields.
>
> This is bascially analogous to 96be4325f443 ("ebpf: add sched_cls_type
> and map it to sk_filter's verifier ops").
>
> BPF_PROG_TYPE_SCHED_CLS and BPF_PROG_TYPE_SCHED_ACT need to be
> separate since both will have a different set of functionality in
> future (classifier vs action), thus we won't run into ABI troubles
> when the point in time comes to diverge functionality from the
> classifier.
>
> The future plan for act_bpf would be that it will be able to write
> into skb->data and alter selected fields mirrored in struct __sk_buff.
>
> For an initial support, it's sufficient to map it to sk_filter_ops.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Jiri Pirko <jiri@resnulli.us>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
