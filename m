From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf/samples: Fix PT_REGS_IP on s390x and use it
Date: Mon, 28 Nov 2016 16:27:06 -0500 (EST)
Message-ID: <20161128.162706.282319625743711116.davem@davemloft.net>
References: <20161128134830.44cd7c1f@TP-holzheu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org, heiko.carstens@de.ibm.com,
        schwidefsky@de.ibm.com
To: holzheu@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753352AbcK1V1J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:27:09 -0500
In-Reply-To: <20161128134830.44cd7c1f@TP-holzheu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Date: Mon, 28 Nov 2016 13:48:30 +0100

> The files "sampleip_kern.c" and "trace_event_kern.c" directly access
> "ctx->regs.ip" which is not available on s390x. Fix this and use the
> PT_REGS_IP() macro instead.
> 
> Also fix the macro for s390x and use "psw.addr" from "pt_regs".
> 
> Reported-by: Zvonko Kosic <zvonko.kosic@de.ibm.com>
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
