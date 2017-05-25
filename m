From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] test_bpf: Add a couple of tests for BPF_JSGE.
Date: Thu, 25 May 2017 14:39:22 -0400 (EDT)
Message-ID: <20170525.143922.468217376527455487.davem@davemloft.net>
References: <20170524233549.18388-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: david.daney@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60426 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757316AbdEYSj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 14:39:26 -0400
In-Reply-To: <20170524233549.18388-1-david.daney@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>
Date: Wed, 24 May 2017 16:35:49 -0700

> Some JITs can optimize comparisons with zero.  Add a couple of
> BPF_JSGE tests against immediate zero.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Applied, thank you.

This reminds me that I should add support for "branch on register"
to the sparc64 eBPF JIT.  At least now, when I do so, there will
be tests for it :-)
