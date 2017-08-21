From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] MIPS,bpf: Improvements for MIPS eBPF JIT
Date: Sun, 20 Aug 2017 20:06:19 -0700 (PDT)
Message-ID: <20170820.200619.821714603187353951.davem@davemloft.net>
References: <20170818234033.5990-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
To: david.daney@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdHUDGV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 23:06:21 -0400
In-Reply-To: <20170818234033.5990-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>
Date: Fri, 18 Aug 2017 16:40:30 -0700

> I suggest that the whole thing go via the BPF/net-next path as there
> are dependencies on code that is not yet merged to Linus' tree.

What kind of dependency?  On networking or MIPS changes?

If the dependency is on MIPS changes, then if I cannot apply this as
it will break the net-next build on MIPS.  You should merge this
via the MIPS tree, where the dependencies are, in that case.

Please clarify what is specifically happening here.

Thanks.
