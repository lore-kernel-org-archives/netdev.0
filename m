From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 0/2] Introduce bpf_prog ID and iteration
Date: Thu, 27 Apr 2017 15:36:59 +0200
Message-ID: <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
References: <20170427062449.80290-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:52515 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751294AbdD0NhB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 09:37:01 -0400
In-Reply-To: <20170427062449.80290-1-kafai@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.04.2017 08:24, Martin KaFai Lau wrote:
> This patchset introduces the bpf_prog ID and a new bpf cmd to
> iterate all bpf_prog in the system.
> 
> It is still incomplete.  The idea can be extended to bpf_map.
> 
> Martin KaFai Lau (2):
>   bpf: Introduce bpf_prog ID
>   bpf: Test for bpf_prog ID and BPF_PROG_GET_NEXT_ID

Thanks Martin, I like the approach.

I think the progid is also much more suitable to be used in kallsyms
because it handles collisions correctly and let's correctly walk the
chain (for example imaging loading two identical programs but install
them at different hooks, kallsysms doesn't allow to find out which
program is installed where).

It would help a lot if you could pass the prog_id back during program
creation, otherwise it will be kind of difficult to get a hold on which
program is where. ;)

Thanks,
Hannes
