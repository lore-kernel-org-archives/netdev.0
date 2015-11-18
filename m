From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arm64: bpf: fix buffer pointer
Date: Wed, 18 Nov 2015 15:34:26 -0500 (EST)
Message-ID: <20151118.153426.1337800771384292183.davem@davemloft.net>
References: <1447836962-4086-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	daniel@iogearbox.net, yang.shi@linaro.org, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: zlim.lnx@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447836962-4086-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zi Shen Lim <zlim.lnx@gmail.com>
Date: Wed, 18 Nov 2015 00:56:02 -0800

> During code review, I noticed we were passing a bad buffer pointer
> to bpf_load_pointer helper function called by jitted code.
> 
> Point to the buffer allocated by JIT, so we don't silently corrupt
> other parts of the stack.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>

Can I get some review from other ARM folks before I apply this?

Thanks.
