From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: bpf: only build
 bpf_jit_binary_{alloc,free}() when jit selected
Date: Wed, 10 Sep 2014 14:05:43 -0700 (PDT)
Message-ID: <20140910.140543.1884964178670505351.davem@davemloft.net>
References: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbaIJVFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 17:05:44 -0400
In-Reply-To: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 10 Sep 2014 15:01:02 +0200

> Since BPF JIT depends on the availability of module_alloc() and
> module_free() helpers (HAVE_BPF_JIT and MODULES), we better build
> that code only in case we have BPF_JIT in our config enabled, just
> like with other JIT code. Fixes builds for arm/marzen_defconfig
> and sh/rsk7269_defconfig.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Fixes: 738cbe72adc5 ("net: bpf: consolidate JIT binary allocator")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  v1->v2:
>   - Sorry, we can reduce it further and remove the else part of
>     the code as bpf_jit_binary_{alloc,free} helpers are only used
>     from within JIT code anyway, of course.

Applied, thanks.
