From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net] selftests/bpf: fix broken build, take 2
Date: Mon, 20 Mar 2017 08:45:25 -0700
Message-ID: <20170320154523.GA80094@ast-mbp.thefacebook.com>
References: <1489989794-6859-1-git-send-email-zlim.lnx@gmail.com>
 <58CFF5D0.8040708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35038 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753614AbdCTPpb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 11:45:31 -0400
Received: by mail-pf0-f193.google.com with SMTP id n11so6533188pfg.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 08:45:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <58CFF5D0.8040708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 04:31:28PM +0100, Daniel Borkmann wrote:
> On 03/20/2017 07:03 AM, Zi Shen Lim wrote:
> >Merge of 'linux-kselftest-4.11-rc1':
> >
> >1. Partially removed use of 'test_objs' target, breaking force rebuild of
> >BPFOBJ, introduced in commit d498f8719a09 ("bpf: Rebuild bpf.o for any
> >dependency update").
> >
> >   Update target so dependency on BPFOBJ is restored.
> >
> >2. Introduced commit 2047f1d8ba28 ("selftests: Fix the .c linking rule")
> >which fixes order of LDLIBS.
> >
> >   Commit d02d8986a768 ("bpf: Always test unprivileged programs") added
> >libcap dependency into CFLAGS. Use LDLIBS instead to fix linking of
> >test_verifier.
> >
> >3. Introduced commit d83c3ba0b926 ("selftests: Fix selftests build to
> >just build, not run tests").
> >
> >   Reordering the Makefile allows us to remove the 'all' target.
> >
> >Tested both:
> >     selftests/bpf$ make
> >and
> >     selftests$ make TARGETS=bpf
> >on Ubuntu 16.04.2.
> >
> >Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> 
> Looks reasonable to me as follow up to 1da8ac7c49fb ("selftests/bpf:
> fix broken build"), thanks for fixing Zi!
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Tested-by: Daniel Borkmann <daniel@iogearbox.net>

worked for me as well:
Acked-by: Alexei Starovoitov <ast@kernel.org>
Tested-by: Alexei Starovoitov <ast@kernel.org>
