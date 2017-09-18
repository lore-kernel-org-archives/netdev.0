From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: devmap: pass on return value of
 bpf_map_precharge_memlock
Date: Mon, 18 Sep 2017 16:53:57 -0700 (PDT)
Message-ID: <20170918.165357.480851390980422798.davem@davemloft.net>
References: <20170918130346.10833-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, john.fastabend@gmail.com,
        netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdIRXyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:54:00 -0400
In-Reply-To: <20170918130346.10833-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 18 Sep 2017 15:03:46 +0200

> If bpf_map_precharge_memlock in dev_map_alloc, -ENOMEM is returned
> regardless of the actual error produced by bpf_map_precharge_memlock.
> Fix it by passing on the error returned by bpf_map_precharge_memlock.
> 
> Also return -EINVAL instead of -ENOMEM if the page count overflow check
> fails.
> 
> This makes dev_map_alloc match the behavior of other bpf maps' alloc
> functions wrt. return values.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thank you.
