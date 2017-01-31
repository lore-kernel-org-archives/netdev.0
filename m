From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 1/6] tools lib bpf: Add BPF program pinning
 APIs.
Date: Tue, 31 Jan 2017 13:08:27 -0300
Message-ID: <20170131160827.GA4529@kernel.org>
References: <20170126212001.14103-1-joe@ovn.org>
 <20170126212001.14103-2-joe@ovn.org>
 <20170130202506.GF4546@kernel.org>
 <20170130202813.GG4546@kernel.org>
 <CAPWQB7FDThp03e6DTHio8Myv5e8J6RcDXK-jG8W6B7Sh2Gvisw@mail.gmail.com>
 <20170131005805.GI4546@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60084 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbdAaQIh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 11:08:37 -0500
Content-Disposition: inline
In-Reply-To: <20170131005805.GI4546@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Jan 30, 2017 at 09:58:05PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Mon, Jan 30, 2017 at 01:16:18PM -0800, Joe Stringer escreveu:
> > On 30 January 2017 at 12:28, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> > > ---
> > > Thus, a return value of size or more means that the output was
> > > truncated.
> > > ---
>  
> > Good spotting, I looked over the committed versions and tested them,
> > they seem good to me. Thanks!
> 
> Thanks for checking, will push Ingo's way after a battery of extra
> tests, tomorrow,

Which failed for centos:5, centos:6, centos:7, debian:7, debian:8,
debian:experimental and others, I stopped the test at this point,
working on fixing it.

All seems related to:

libbpf.c:1267: error: 'BPF_FS_MAGIC' undeclared (first use in this function)
libbpf.c:1267: error: (Each undeclared identifier is reported only once
libbpf.c:1267: error: for each function it appears in.)
