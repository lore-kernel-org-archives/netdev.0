From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] arm64: bpf: fix JIT frame pointer setup
Date: Mon, 16 Nov 2015 14:39:27 -0500 (EST)
Message-ID: <20151116.143927.1891085632150496414.davem@davemloft.net>
References: <1447365421-1309-1-git-send-email-yang.shi@linaro.org>
	<1447365421-1309-2-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, catalin.marinas@arm.com,
	will.deacon@arm.com, zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbKPTja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 14:39:30 -0500
In-Reply-To: <1447365421-1309-2-git-send-email-yang.shi@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Shi <yang.shi@linaro.org>
Date: Thu, 12 Nov 2015 13:57:00 -0800

> BPF fp should point to the top of the BPF prog stack. The original
> implementation made it point to the bottom incorrectly.
> Move A64_SP to fp before reserve BPF prog stack space.
> 
> CC: Zi Shen Lim <zlim.lnx@gmail.com>
> CC: Xi Wang <xi.wang@gmail.com>
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied.
