From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: bpf_event_entry_gen's alloc needs to be
 in atomic context
Date: Sat, 16 Jul 2016 22:04:35 -0700 (PDT)
Message-ID: <20160716.220435.333365058859593808.davem@davemloft.net>
References: <3a4cacd7ebd8b246325c48b46d25d67669428198.1468624006.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbcGQFEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 01:04:37 -0400
In-Reply-To: <3a4cacd7ebd8b246325c48b46d25d67669428198.1468624006.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 16 Jul 2016 01:15:55 +0200

> Should have been obvious, only called from bpf() syscall via map_update_elem()
> that calls bpf_fd_array_map_update_elem() under RCU read lock and thus this
> must also be in GFP_ATOMIC, of course.
> 
> Fixes: 3b1efb196eee ("bpf, maps: flush own entries on perf map release")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.
