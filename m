From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: add missing map_flags to bpf_map_show_fdinfo
Date: Fri, 25 Mar 2016 11:37:05 -0400 (EDT)
Message-ID: <20160325.113705.1506548943081346934.davem@davemloft.net>
References: <5da67066a9739eb443b2e89e58ea4d356d70459c.1458861762.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbcCYPhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 11:37:07 -0400
In-Reply-To: <5da67066a9739eb443b2e89e58ea4d356d70459c.1458861762.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 25 Mar 2016 00:30:25 +0100

> Add map_flags attribute to bpf_map_show_fdinfo(), so that tools like
> tc can check for them when loading objects from a pinned entry, e.g.
> if user intent wrt allocation (BPF_F_NO_PREALLOC) is different to the
> pinned object, it can bail out. Follow-up to 6c9059817432 ("bpf:
> pre-allocate hash map elements"), so that tc can still support this
> with v4.6.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Daniel.
