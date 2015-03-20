From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] ebpf: add sched_act_type and map it to
 sk_filter's verifier ops
Date: Fri, 20 Mar 2015 15:21:29 +0100
Message-ID: <20150320142129.GF2223@nanopsycho.brq.redhat.com>
References: <cover.1426859241.git.daniel@iogearbox.net>
 <3f1f15c00b7dd9899035696eef924b23a008afc2.1426859241.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:34426 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbbCTOVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:21:32 -0400
Received: by wegp1 with SMTP id p1so83322209weg.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 07:21:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <3f1f15c00b7dd9899035696eef924b23a008afc2.1426859241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 20, 2015 at 03:11:11PM CET, daniel@iogearbox.net wrote:
>In order to prepare eBPF support for tc action, we need to add
>sched_act_type, so that the eBPF verifier is aware of what helper
>function act_bpf may use, that it can load skb data and read out
>currently available skb fields.
>
>This is bascially analogous to 96be4325f443 ("ebpf: add sched_cls_type
>and map it to sk_filter's verifier ops").
>
>BPF_PROG_TYPE_SCHED_CLS and BPF_PROG_TYPE_SCHED_ACT need to be
>separate since both will have a different set of functionality in
>future (classifier vs action), thus we won't run into ABI troubles
>when the point in time comes to diverge functionality from the
>classifier.
>
>The future plan for act_bpf would be that it will be able to write
>into skb->data and alter selected fields mirrored in struct __sk_buff.
>
>For an initial support, it's sufficient to map it to sk_filter_ops.
>
>Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>Cc: Jiri Pirko <jiri@resnulli.us>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
