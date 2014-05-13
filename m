From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net, filter: make new test_bpf depend on networking
Date: Tue, 13 May 2014 17:13:38 -0400 (EDT)
Message-ID: <20140513.171338.874422171651978643.davem@davemloft.net>
References: <alpine.DEB.2.02.1405131255380.3392@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rientjes@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbaEMVNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 17:13:42 -0400
In-Reply-To: <alpine.DEB.2.02.1405131255380.3392@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rientjes <rientjes@google.com>
Date: Tue, 13 May 2014 12:57:56 -0700 (PDT)

> CONFIG_TEST_BPF depends on CONFIG_NET, otherwise the build fails:
> 
> ERROR: "sk_unattached_filter_destroy" [lib/test_bpf.ko] undefined!
> ERROR: "kfree_skb" [lib/test_bpf.ko] undefined!
> ERROR: "sk_unattached_filter_create" [lib/test_bpf.ko] undefined!
> ERROR: "sk_run_filter_int_skb" [lib/test_bpf.ko] undefined!
> ERROR: "__alloc_skb" [lib/test_bpf.ko] undefined!
> 
> Add the dependency.
> 
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

I just applied a patch from Randy Dunlap that does the same thing,
thanks.
