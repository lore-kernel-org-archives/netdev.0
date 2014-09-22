From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bpf: fix compiler warnings in test_bpf
Date: Mon, 22 Sep 2014 16:22:01 -0400 (EDT)
Message-ID: <20140922.162201.725520596022239878.davem@davemloft.net>
References: <1411160031-3538-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, fengguang.wu@intel.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbaIVUWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:22:03 -0400
In-Reply-To: <1411160031-3538-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 19 Sep 2014 13:53:51 -0700

> old gcc 4.2 used by avr32 architecture produces warnings:
> 
> lib/test_bpf.c:1741: warning: integer constant is too large for 'long' type
> lib/test_bpf.c:1741: warning: integer constant is too large for 'long' type
> lib/test_bpf.c: In function '__run_one':
> lib/test_bpf.c:1897: warning: 'ret' may be used uninitialized in this function
> 
> silence these warnings.
> 
> Fixes: 02ab695bb37e ("net: filter: add "load 64-bit immediate" eBPF instruction")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thank you.
