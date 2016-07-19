From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch 1/1] kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon
 union initialization bug
Date: Mon, 18 Jul 2016 17:33:07 -0700
Message-ID: <20160719003305.GA45296@ast-mbp.thefacebook.com>
References: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
	daniel@iogearbox.net, Fengguang Wu <fengguang.wu@intel.com>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33964 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbcGSAdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 20:33:11 -0400
Received: by mail-pa0-f65.google.com with SMTP id hh10so202563pac.1
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 17:33:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <578d5d52.lh08e3GTSq3vxxIL%akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 03:50:58PM -0700, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: kernel/trace/bpf_trace.c: work around gcc-4.4.4 anon union initialization bug
> 
> kernel/trace/bpf_trace.c: In function 'bpf_event_output':
> kernel/trace/bpf_trace.c:312: error: unknown field 'next' specified in initializer
> kernel/trace/bpf_trace.c:312: warning: missing braces around initializer
> kernel/trace/bpf_trace.c:312: warning: (near initialization for 'raw.frag.<anonymous>')
> 
> Fixes: 555c8a8623a3a87 ("bpf: avoid stack copy and use skb ctx for event output")
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Alexei Starovoitov <ast@kernel.org>

Fengguang can you add gcc-4.4 to buildbot. Thanks!
