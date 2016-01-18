From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] arm64: bpf: add extra pass to handle faulty codegen
Date: Sun, 17 Jan 2016 19:15:45 -0500 (EST)
Message-ID: <20160117.191545.670534349073994378.davem@davemloft.net>
References: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
	<1452756802-16511-2-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, will.deacon@arm.com, catalin.marinas@arm.com,
	rabin@rab.in, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: zlim.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbcARAPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:15:48 -0500
In-Reply-To: <1452756802-16511-2-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zi Shen Lim <zlim.lnx@gmail.com>
Date: Wed, 13 Jan 2016 23:33:22 -0800

> Code generation functions in arch/arm64/kernel/insn.c previously
> BUG_ON invalid parameters. Following change of that behavior, now we
> need to handle the error case where AARCH64_BREAK_FAULT is returned.
> 
> Instead of error-handling on every emit() in JIT, we add a new
> validation pass at the end of JIT compilation. There's no point in
> running JITed code at run-time only to trap due to AARCH64_BREAK_FAULT.
> Instead, we drop this failed JIT compilation and allow the system to
> gracefully fallback on the BPF interpreter.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> Suggested-by: Alexei Starovoitov <ast@kernel.org>

Applied.
