From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] act_bpf update
Date: Fri, 20 Mar 2015 18:21:43 -0400 (EDT)
Message-ID: <20150320.182143.1083193219152410363.davem@davemloft.net>
References: <cover.1426859241.git.daniel@iogearbox.net>
	<20150320.162252.977628965847070194.davem@davemloft.net>
	<550C8CCC.7060901@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbCTWVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:21:45 -0400
In-Reply-To: <550C8CCC.7060901@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 20 Mar 2015 22:10:36 +0100

> So my HEAD is at latest net-next commit b4c11cb437fdb34b ("Merge
> branch
> 'amd-xgbe-next'"):
> 
>   $ git cherry-pick ced585c83b27deca427c606a34dd3eaa6b96d82b
>   [ebpf-act 1b8dfa9] act_bpf: allow non-default TC_ACT opcodes as BPF
>   exec outcome
>    1 file changed, 28 insertions(+), 8 deletions(-)
>   $ git am
>   0001-ebpf-add-sched_act_type-and-map-it-to-sk_filter-s-ve.patch
>   Applying: ebpf: add sched_act_type and map it to sk_filter's verifier
>   ops
>   $ git am 0002-act_bpf-add-initial-eBPF-support-for-actions.patch
>   Applying: act_bpf: add initial eBPF support for actions
>   $
> 
> The dependency mentioned in the cover letter is on net commit
> ced585c83b27
> ("act_bpf: allow non-default TC_ACT opcodes as BPF exec outcome"). On
> my
> side that applies fine, hm.

Sorry, my bad, I'll sort this out.
