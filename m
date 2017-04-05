From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: emac: remove unused sysrq handler for 'c' key
Date: Wed, 05 Apr 2017 07:26:36 -0700 (PDT)
Message-ID: <20170405.072636.1936712503456383299.davem@davemloft.net>
References: <20170404055020.30658-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivan@de.ibm.com,
        linux-kernel@vger.kernel.org, ebiggers@google.com
To: ebiggers3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753091AbdDEO0l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:26:41 -0400
In-Reply-To: <20170404055020.30658-1-ebiggers3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Biggers <ebiggers3@gmail.com>
Date: Mon,  3 Apr 2017 22:50:20 -0700

> From: Eric Biggers <ebiggers@google.com>
> 
> Since commit d6580a9f1523 ("kexec: sysrq: simplify sysrq-c handler"),
> the sysrq handler for the 'c' key has been sysrq_crash_op.  Debugging
> code in the ibm_emac driver also tries to register a handler for the 'c'
> key, but this has no effect because register_sysrq_key() doesn't replace
> existing handlers.  Since evidently no one has cared enough to fix this
> in the last 8 years, and it's very rare for drivers to register sysrq
> handlers (for good reason), just remove the dead code.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied to net-next, thanks.
