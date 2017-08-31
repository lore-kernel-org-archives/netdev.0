From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: Fix compilation issue in
 redirect dummy program
Date: Thu, 31 Aug 2017 11:58:07 -0700 (PDT)
Message-ID: <20170831.115807.699861430358386392.davem@davemloft.net>
References: <1504178199-12410-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, brouer@redhat.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751727AbdHaS6H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 14:58:07 -0400
In-Reply-To: <1504178199-12410-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 31 Aug 2017 14:16:39 +0300

> Fix compilation error below:
> 
> $ make samples/bpf/
> 
> LLVM ERROR: 'xdp_redirect_dummy' label emitted multiple times to
> assembly file
> make[1]: *** [samples/bpf/xdp_redirect_kern.o] Error 1
> make: *** [samples/bpf/] Error 2
> 
> Fixes: 306da4e685b4 ("samples/bpf: xdp_redirect load XDP dummy prog on TX device")
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied.
