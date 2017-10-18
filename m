From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net PATCH 1/5] bpf: enforce TCP only support for sockmap
Date: Wed, 18 Oct 2017 10:33:38 -0700
Message-ID: <20171018173336.ty7qgjuauqgeqnp3@ast-mbp>
References: <150833522977.3588.14633565129152334098.stgit@john-XPS-13-9360>
 <150833581505.3588.4222223777453171460.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, borkmann@iogearbox.net
To: John Fastabend <john.r.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:48143 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbdJRRdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:33:41 -0400
Received: by mail-pg0-f51.google.com with SMTP id v78so4833570pgb.5
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:33:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150833581505.3588.4222223777453171460.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 07:10:15AM -0700, John Fastabend wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> 
> Only TCP sockets have been tested and at the moment the state change
> callback only handles TCP sockets. This adds a check to ensure that
> sockets actually being added are TCP sockets.
> 
> For net-next we can consider UDP support.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
