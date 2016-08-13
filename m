From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] bpf: fix bpf_skb_in_cgroup helper naming
Date: Fri, 12 Aug 2016 23:14:02 -0700
Message-ID: <20160813061402.GA68945@kafai-mba.local>
References: <f08aab1ab054e7609ff3dc1632c4cc4603636d7d.1471031665.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <alexei.starovoitov@gmail.com>,
	<tj@kernel.org>, <sargun@sargun.me>, <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:2072 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751496AbcHMGOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 02:14:32 -0400
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
Thanks for working on this and be-lated

Acked-by: Martin KaFai Lau <kafai@fb.com>
