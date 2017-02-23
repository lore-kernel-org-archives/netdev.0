From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: Fix bpf_xdp_event_output
Date: Thu, 23 Feb 2017 19:49:25 +0100
Message-ID: <58AF2EB5.1000902@iogearbox.net>
References: <1487875234-886444-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54934 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdBWSu2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 13:50:28 -0500
In-Reply-To: <1487875234-886444-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2017 07:40 PM, Martin KaFai Lau wrote:
> Fix a typo. xdp->data instead of xdp should be copied to the perf-event's
> dst_buff.
>
> Fixes: 4de16969523c ("bpf: enable event output helper also for xdp types")
> Reported-by: Huapeng Zhou <hzhou@fb.com>
> Tested-by: Feixiong Zhang <feixiong@fb.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks!
