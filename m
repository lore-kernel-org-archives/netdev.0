From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 6/9] bpf: harden sockmap program attach to
 ensure correct map type
Date: Mon, 28 Aug 2017 10:33:15 -0700
Message-ID: <20170828173314.3pcv2tmfhprkt2sp@ast-mbp>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
 <20170828141143.14143.89655.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35339 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751249AbdH1RdS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:33:18 -0400
Received: by mail-pf0-f176.google.com with SMTP id g13so3109837pfm.2
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:33:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170828141143.14143.89655.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 07:11:43AM -0700, John Fastabend wrote:
> When attaching a program to sockmap we need to check map type
> is correct.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

good catch. Great to see that you're adding a test for it too.

Acked-by: Alexei Starovoitov <ast@kernel.org>
