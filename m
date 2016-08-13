From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix bpf_skb_in_cgroup helper naming
Date: Fri, 12 Aug 2016 21:53:56 -0700 (PDT)
Message-ID: <20160812.215356.268607618202188381.davem@davemloft.net>
References: <f08aab1ab054e7609ff3dc1632c4cc4603636d7d.1471031665.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, kafai@fb.com, tj@kernel.org,
	sargun@sargun.me, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcHMFCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 01:02:45 -0400
In-Reply-To: <f08aab1ab054e7609ff3dc1632c4cc4603636d7d.1471031665.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 12 Aug 2016 22:17:17 +0200

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

Applied.
