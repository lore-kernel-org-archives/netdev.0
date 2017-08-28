From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 8/9] bpf: sockmap requires STREAM_PARSER add
 Kconfig entry
Date: Mon, 28 Aug 2017 10:34:52 -0700
Message-ID: <20170828173451.pf2dhaofxczfeqoj@ast-mbp>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
 <20170828141221.14143.27371.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36874 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdH1Rez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:34:55 -0400
Received: by mail-pf0-f195.google.com with SMTP id a2so720139pfj.4
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:34:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170828141221.14143.27371.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 07:12:21AM -0700, John Fastabend wrote:
> SOCKMAP uses strparser code (compiled with Kconfig option
> CONFIG_STREAM_PARSER) to run the parser BPF program. Without this
> config option set sockmap wont be compiled. However, at the moment
> the only way to pull in the strparser code is to enable KCM.
> 
> To resolve this create a BPF specific config option to pull
> only the strparser piece in that sockmap needs. This also
> allows folks who want to use BPF/syscall/maps but don't need
> sockmap to easily opt out.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
