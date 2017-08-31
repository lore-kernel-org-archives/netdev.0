From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] samples/bpf: Fix compilation issue in redirect
 dummy program
Date: Thu, 31 Aug 2017 13:27:10 +0200
Message-ID: <20170831132710.3b245a6a@redhat.com>
References: <1504178199-12410-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50520 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751250AbdHaL1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 07:27:16 -0400
In-Reply-To: <1504178199-12410-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 31 Aug 2017 14:16:39 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

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
> ---

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

What LLVM/clang version do you use?

I don't see this compile error, and I have:
 $ clang --version
 clang version 3.9.1 (tags/RELEA

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
