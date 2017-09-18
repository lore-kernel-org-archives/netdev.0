From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: devmap: pass on return value of
 bpf_map_precharge_memlock
Date: Mon, 18 Sep 2017 08:57:10 -0700
Message-ID: <20170918155706.dtqxrffmw3ttnztg@ast-mbp.dhcp.thefacebook.com>
References: <20170918130346.10833-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        John Fastabend <john.fastabend@gmail.com>,
        netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:47185 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755765AbdIRP5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 11:57:14 -0400
Received: by mail-pg0-f45.google.com with SMTP id d8so355175pgt.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 08:57:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170918130346.10833-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 03:03:46PM +0200, Tobias Klauser wrote:
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

good catch.
Acked-by: Alexei Starovoitov <ast@kernel.org>
