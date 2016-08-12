From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: fix bpf_skb_in_cgroup helper naming
Date: Fri, 12 Aug 2016 16:06:42 -0700
Message-ID: <20160812230640.GA48651@ast-mbp.thefacebook.com>
References: <f08aab1ab054e7609ff3dc1632c4cc4603636d7d.1471031665.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kafai@fb.com, tj@kernel.org, sargun@sargun.me,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33205 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbcHLXGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 19:06:47 -0400
Received: by mail-pf0-f193.google.com with SMTP id i6so39487pfe.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 16:06:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f08aab1ab054e7609ff3dc1632c4cc4603636d7d.1471031665.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 10:17:17PM +0200, Daniel Borkmann wrote:
> While hashing out BPF's current_task_under_cgroup helper bits, it came
> to discussion that the skb_in_cgroup helper name was suboptimally chosen.
> 
> Tejun says:
> 
>   So, I think in_cgroup should mean that the object is in that
>   particular cgroup while under_cgroup in the subhierarchy of that
>   cgroup. Let's rename the other subhierarchy test to under too. I
>   think that'd be a lot less confusing going forward.
> 
>   [...]
> 
>   It's more intuitive and gives us the room to implement the real
>   "in" test if ever necessary in the future.
> 
> Since this touches uapi bits, we need to change this as long as v4.8
> is not yet officially released. Thus, change the helper enum and rename
> related bits.
> 
> Fixes: 4a482f34afcc ("cgroup: bpf: Add bpf_skb_in_cgroup_proto")
> Reference: http://patchwork.ozlabs.org/patch/658500/
> Suggested-by: Sargun Dhillon <sargun@sargun.me>
> Suggested-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
