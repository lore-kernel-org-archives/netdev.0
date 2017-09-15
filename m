From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf/verifier: reject BPF_ALU64|BPF_END
Date: Fri, 15 Sep 2017 08:50:46 -0700
Message-ID: <20170915155044.e3jbkdbdbkaq7zun@ast-mbp>
References: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37681 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751152AbdIOPup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 11:50:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id e69so1405773pfg.4
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 08:50:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 02:37:38PM +0100, Edward Cree wrote:
> Neither ___bpf_prog_run nor the JITs accept it.
> Also adds a new test case.
> 
> Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Good catch. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
