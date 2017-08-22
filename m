From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] MIPS,bpf: fix missing break in switch
 statement
Date: Tue, 22 Aug 2017 16:18:24 -0700 (PDT)
Message-ID: <20170822.161824.223361546462600595.davem@davemloft.net>
References: <20170822224606.6273-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47050 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752332AbdHVXS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 19:18:26 -0400
In-Reply-To: <20170822224606.6273-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Tue, 22 Aug 2017 23:46:06 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> There is a missing break causing a fall-through and setting
> ctx.use_bbit_insns to the wrong value. Fix this by adding the
> missing break.
> 
> Detected with cppcheck:
> "Variable 'ctx.use_bbit_insns' is reassigned a value before the old
> one has been used. 'break;' missing?"
> 
> Fixes: 8d8d18c3283f ("MIPS,bpf: Fix using smp_processor_id() in preemptible splat.")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Acked-by: David Daney <david.daney@cavium.com>

Applied, thanks.
