From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: remove self-assignment in interpreter's
 tail call
Date: Mon, 13 Jul 2015 13:12:16 -0700 (PDT)
Message-ID: <20150713.131216.1152635752338498540.davem@davemloft.net>
References: <6586042063b52e17a355fce15460ee16c1ee95bf.1436812762.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbbGMUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 16:12:16 -0400
In-Reply-To: <6586042063b52e17a355fce15460ee16c1ee95bf.1436812762.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 13 Jul 2015 20:49:32 +0200

> ARG1 = BPF_R1 as it stands, evaluates to regs[BPF_REG_1] = regs[BPF_REG_1]
> and thus has no effect. Add a comment instead, explaining what happens and
> why it's okay to just remove it. Since from user space side, a tail call is
> invoked as a pseudo helper function via bpf_tail_call_proto, the verifier
> checks the arguments just like with any other helper function and makes
> sure that the first argument (regs[BPF_REG_1])'s type is ARG_PTR_TO_CTX.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
