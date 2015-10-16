From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Need to call bpf_prog_uncharge_memlock
 from bpf_prog_put
Date: Fri, 16 Oct 2015 01:02:43 -0700 (PDT)
Message-ID: <20151016.010243.933964845168218651.davem@davemloft.net>
References: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630AbbJPHqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:46:34 -0400
In-Reply-To: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 14 Oct 2015 14:40:44 -0700

> Currently, is only called from __prog_put_rcu in the bpf_prog_release
> path. Need this to call this from bpf_prog_put also to get correct
> accounting.
> 
> Fixes: commit aaac3ba95e4c8b49 ("bpf: charge user for creation of BPF maps and programs")
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Applied, with Fixes: tag fixed.
