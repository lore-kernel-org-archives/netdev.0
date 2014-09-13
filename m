From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bpf: correctly handle errors in sk_attach_filter()
Date: Sat, 13 Sep 2014 17:38:05 -0400 (EDT)
Message-ID: <20140913.173805.566607253438396851.davem@davemloft.net>
References: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, keescook@chromium.org,
	hannes@stressinduktion.org, dborkman@redhat.com,
	spender@grsecurity.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbaIMViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 17:38:08 -0400
In-Reply-To: <1410581190-31922-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sat, 13 Sep 2014 00:06:30 -0400

> Commit "net: bpf: make eBPF interpreter images read-only" has changed bpf_prog
> to be vmalloc()ed but never handled some of the errors paths of the old code.
> 
> On error within sk_attach_filter (which userspace can easily trigger), we'd
> kfree() the vmalloc()ed memory, and leak the internal bpf_work_struct.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied.
