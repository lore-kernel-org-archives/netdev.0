From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: include perf_event only where really
 needed
Date: Mon, 05 Oct 2015 07:05:14 -0700 (PDT)
Message-ID: <20151005.070514.1514093354970065851.davem@davemloft.net>
References: <1e7712d4d7b8638ad96ca74436fe96508ce89dfa.1443802548.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, xiakaixu@huawei.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbJENtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 09:49:42 -0400
In-Reply-To: <1e7712d4d7b8638ad96ca74436fe96508ce89dfa.1443802548.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  2 Oct 2015 18:42:00 +0200

> Commit ea317b267e9d ("bpf: Add new bpf map type to store the pointer
> to struct perf_event") added perf_event.h to the main eBPF header, so
> it gets included for all users. perf_event.h is actually only needed
> from array map side, so lets sanitize this a bit.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.

>  [ Did couple of tests, but lets see if Fengguang's build bot agrees
>    with me eventually. ;) P.s., the feature of pulling patches from
>    patchwork is awesome! ]

Agreed.  :-)
