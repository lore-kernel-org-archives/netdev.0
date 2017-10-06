From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 1/3] samples/bpf: xdp_monitor first 8 bytes are
 not accessible by bpf
Date: Fri, 6 Oct 2017 09:13:27 -0700
Message-ID: <20171006161325.274axwwcgliuxmkz@ast-mbp.dhcp.thefacebook.com>
References: <150727927390.4460.3200093291677318710.stgit@firesoul>
 <150727930151.4460.3117254071267380300.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35192 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdJFQNb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 12:13:31 -0400
Received: by mail-pf0-f196.google.com with SMTP id i23so17108806pfi.2
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 09:13:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150727930151.4460.3117254071267380300.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 06, 2017 at 10:41:41AM +0200, Jesper Dangaard Brouer wrote:
> The first 8 bytes of the tracepoint context struct are not accessible
> by the bpf code.  This is a choice that dates back to the original
> inclusion of this code.
> 
> See explaination in:
>  commit 98b5c2c65c29 ("perf, bpf: allow bpf programs attach to tracepoints")
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

thank you for fixing it.
Acked-by: Alexei Starovoitov <ast@kernel.org>
