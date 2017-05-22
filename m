From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kernel: bpf: remove dead code
Date: Mon, 22 May 2017 10:38:00 -0400 (EDT)
Message-ID: <20170522.103800.1354089494827582585.davem@davemloft.net>
References: <20170522140746.GA10113@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522140746.GA10113@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Mon, 22 May 2017 09:07:46 -0500

> Execution cannot reach NET_IP_ALIGN inside the following statement:
> ip_align = strict ? 2 : NET_IP_ALIGN
> 
> Addresses-Coverity-ID: 1409762
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
> NOTE: variable ip_align could also be removed and use value 2 directly.

Incorrect.

Some platforms define NET_IP_ALIGN to zero, so the code must remain
as is.
