From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tools: bpf_jit_disasm: fix segfault on disabled
 debugging log output
Date: Wed, 27 May 2015 00:24:21 -0400 (EDT)
Message-ID: <20150527.002421.933751602719615067.davem@davemloft.net>
References: <beb215366f62df41ce57bbb523e0c554719cf9c1.1432555472.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbbE0EYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 00:24:23 -0400
In-Reply-To: <beb215366f62df41ce57bbb523e0c554719cf9c1.1432555472.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 25 May 2015 14:08:03 +0200

> With recent debugging, I noticed that bpf_jit_disasm segfaults when
> there's no debugging output from the JIT compiler to the kernel log.
> 
> Reason is that when regexec(3) doesn't match on anything, start/end
> offsets are not being filled out and contain some uninitialized garbage
> from stack. Thus, we need zero out offsets first.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
