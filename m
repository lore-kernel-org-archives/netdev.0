From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH perf/core REBASE 2/5] samples/bpf: Switch over to libbpf
Date: Fri, 16 Dec 2016 12:21:37 -0200
Message-ID: <20161216142137.GF2742@redhat.com>
References: <20161214224342.12858-1-joe@ovn.org>
 <20161214224342.12858-3-joe@ovn.org>
 <20161215155022.GE6866@kernel.org>
 <20161215182918.GG6866@kernel.org>
 <20161215183440.GH6866@kernel.org>
 <CAPWQB7GhHZOf4c5mu=__mNNyFFeq+jOZMawweMBg=sNiPpt-zg@mail.gmail.com>
 <CAPWQB7EAN7Fg8+vO3Tn7WYWcZW_JpKQFNCJzY_K100ckab6JRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Wang Nan <wangnan0@huawei.com>,
        ast@fb.com, Daniel Borkmann <daniel@iogearbox.net>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760750AbcLPOVq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 09:21:46 -0500
Content-Disposition: inline
In-Reply-To: <CAPWQB7EAN7Fg8+vO3Tn7WYWcZW_JpKQFNCJzY_K100ckab6JRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 15, 2016 at 05:48:31PM -0800, Joe Stringer escreveu:
> On 15 December 2016 at 14:00, Joe Stringer <joe@ovn.org> wrote:
> > On 15 December 2016 at 10:34, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> >> So, I'm stopping here so that I can push what I have to Ingo, then I'll get
> >> back to this, hopefully by then you beat me and I have just to retest 8-)

> > OK, thanks for the report. Looks like there was another difference
> > between the two libbpfs - one used total program size for its
> > load_program API; the actual kernel API uses instruction count. This
> > incremental should do the trick:

> > https://github.com/joestringer/linux/commit/6ff7726f20077bed66fb725f5189c13690154b6a
 
> The full branch with this change (fast-forward from your tmp branch)
> is available here:
> https://github.com/joestringer/linux/tree/submit/libbpf_samples_v5
 
> I tried running every selftest and BPF sample I could get my hands on;
> there's one or two that I couldn't run, but seemed more to do with my
> versions of TC/iproute and kernel config rather than libbpf changes.
> Let me know if you see any further trouble.

Thanks for doing that! I'll try and reproduce your tests as soon as I'm
back to the office, it looks like it all will go together in my next
pull to Ingo.

- Arnaldo
