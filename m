From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] net: bpf: only build bpf_jit_binary_{alloc,free}()
 when jit selected
Date: Wed, 10 Sep 2014 10:22:02 -0700
Message-ID: <CAMEtUuzOO3zt45FZj7sR5+iWa+L7hCD32TBkyjW7ZsOg633T4g@mail.gmail.com>
References: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	kbuild test robot <fengguang.wu@intel.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36138 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaIJRWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 13:22:03 -0400
Received: by mail-wi0-f177.google.com with SMTP id em10so2573190wid.4
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 10:22:02 -0700 (PDT)
In-Reply-To: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 6:01 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Since BPF JIT depends on the availability of module_alloc() and
> module_free() helpers (HAVE_BPF_JIT and MODULES), we better build
> that code only in case we have BPF_JIT in our config enabled, just
> like with other JIT code. Fixes builds for arm/marzen_defconfig
> and sh/rsk7269_defconfig.
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: 738cbe72adc5 ("net: bpf: consolidate JIT binary allocator")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

haven't tested it, but looks good to me, so
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

thank you for taking care of it so quickly.
