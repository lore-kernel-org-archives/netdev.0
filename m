From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: add skb->priority to offset map for
 usage in {cls,act}_bpf
Date: Fri, 03 Apr 2015 15:01:10 -0400 (EDT)
Message-ID: <20150403.150110.1330709172614555508.davem@davemloft.net>
References: <e9507df311c2d04e46143ee4bd321f99f917640d.1428086479.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbbDCTBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 15:01:14 -0400
In-Reply-To: <e9507df311c2d04e46143ee4bd321f99f917640d.1428086479.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  3 Apr 2015 20:52:24 +0200

> This adds the ability to read out the skb->priority from an eBPF
> program, so that it can be taken into account from a tc filter
> or action for the use-case where the priority is not being used
> to directly override the filter classification in a qdisc, but
> to tag traffic otherwise for the classifier; the priority can be
> assigned from various places incl. user space, in future we may
> also mangle it from an eBPF program.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

This looks fine, applied, thanks.
