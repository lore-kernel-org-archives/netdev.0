From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] test_bpf: add 173 new testcases for eBPF
Date: Tue, 12 May 2015 23:23:10 -0400 (EDT)
Message-ID: <20150512.232310.389605215659991765.davem@davemloft.net>
References: <1431445096-13698-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934246AbbEMDXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:23:12 -0400
In-Reply-To: <1431445096-13698-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 12 May 2015 08:38:16 -0700

> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> 
> add an exhaustive set of eBPF tests bringing total to:
> test_bpf: Summary: 233 PASSED, 0 FAILED, [0/226 JIT'ed]
> 
> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net> 
> ---
> V1->V2: removed double 'From', added 'Ack'
> 
> these tests found div64 bug in interpreter (already fixed)
> and another cpu_to_be16 bug in x64 JIT (fix is being worked on).

Sorry, I applied V1 of this, and in fact I removed the double From:
when I applied it.

I hope this is ok.
