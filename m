From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf, arm: start flushing icache range from header
Date: Mon, 16 Nov 2015 14:41:46 -0500 (EST)
Message-ID: <20151116.144146.1598629493151443362.davem@davemloft.net>
References: <971980449d680e6b26e273130d74546c5148893c.1447446440.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nschichan@freebox.fr, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbbKPTls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:41:48 -0500
In-Reply-To: <971980449d680e6b26e273130d74546c5148893c.1447446440.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 14 Nov 2015 01:26:53 +0100

> During review I noticed that the icache range we're flushing should
> start at header already and not at ctx.image.
> 
> Reason is that after 55309dd3d4cd ("net: bpf: arm: address randomize
> and write protect JIT code"), we also want to make sure to flush the
> random-sized trap in front of the start of the actual program (analogous
> to x86). No operational differences from user side.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Tested-by: Nicolas Schichan <nschichan@freebox.fr>
> Cc: Alexei Starovoitov <ast@kernel.org>

Applied.
