From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix write helpers with regards to non-linear
 parts
Date: Sat, 13 Aug 2016 15:01:38 -0700 (PDT)
Message-ID: <20160813.150138.275492199968284654.davem@davemloft.net>
References: <c281218e107134c8d30d1aafe2aca15fcf8e43df.1470941847.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbcHNIie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 04:38:34 -0400
In-Reply-To: <c281218e107134c8d30d1aafe2aca15fcf8e43df.1470941847.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 11 Aug 2016 21:38:37 +0200

> Fix the bpf_try_make_writable() helper and all call sites we have in BPF,
> it's currently defect with regards to skbs when the write_len spans into
> non-linear parts, no matter if cloned or not.
 ...
> Fixes: 608cd71a9c7c ("tc: bpf: generalize pedit action")
> Fixes: 91bc4822c3d6 ("tc: bpf: add checksum helpers")
> Fixes: 3697649ff29e ("bpf: try harder on clones when writing into skb")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks.
