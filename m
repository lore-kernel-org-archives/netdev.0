From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] arm64: insn: remove BUG_ON from codegen
Date: Sun, 17 Jan 2016 19:15:40 -0500 (EST)
Message-ID: <20160117.191540.973637884089764401.davem@davemloft.net>
References: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: will.deacon@arm.com, ast@kernel.org, catalin.marinas@arm.com,
	rabin@rab.in, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: zlim.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbcARAPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:15:42 -0500
In-Reply-To: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zi Shen Lim <zlim.lnx@gmail.com>
Date: Wed, 13 Jan 2016 23:33:21 -0800

> During code generation, we used to BUG_ON unknown/unsupported encoding
> or invalid parameters.
> 
> Instead, now we report these as errors and simply return the
> instruction AARCH64_BREAK_FAULT. Users of these codegen helpers should
> check for and handle this failure condition as appropriate.
> 
> Otherwise, unhandled codegen failure will result in trapping at
> run-time due to AARCH64_BREAK_FAULT, which is arguably better than a
> BUG_ON.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>

Applied.
