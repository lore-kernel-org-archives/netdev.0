From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH 3/5] bpf: remove mark access for SK_SKB program types
Date: Wed, 18 Oct 2017 10:34:05 -0700
Message-ID: <20171018173403.5m2d44vxuilciuqt@ast-mbp>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
 <150833585867.3588.14935777843137354788.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, borkmann@iogearbox.net
To: John Fastabend <john.r.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:49357 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdJRReI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:34:08 -0400
Received: by mail-pf0-f193.google.com with SMTP id i5so4462543pfe.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:34:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150833585867.3588.14935777843137354788.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 07:10:58AM -0700, John Fastabend wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> 
> The skb->mark field is a union with reserved_tailroom which is used
> in the TCP code paths from stream memory allocation. Allowing SK_SKB
> programs to set this field creates a conflict with future code
> optimizations, such as "gifting" the skb to the egress path instead
> of creating a new skb and doing a memcpy.
> 
> Because we do not have a released version of SK_SKB yet lets just
> remove it for now. A more appropriate scratch pad to use at the
> socket layer is dev_scratch, but lets add that in future kernels
> when needed.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
