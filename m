From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: make padding in bpf_tunnel_key explicit
Date: Wed, 30 Mar 2016 00:10:43 -0400 (EDT)
Message-ID: <20160330.001043.584711438018970796.davem@davemloft.net>
References: <6589c70157238797e63986eeea67cfe2abfb3260.1459288316.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbcC3EKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 00:10:48 -0400
In-Reply-To: <6589c70157238797e63986eeea67cfe2abfb3260.1459288316.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 30 Mar 2016 00:02:00 +0200

> Make the 2 byte padding in struct bpf_tunnel_key between tunnel_ttl
> and tunnel_label members explicit. No issue has been observed, and
> gcc/llvm does padding for the old struct already, where tunnel_label
> was not yet present, so the current code works, but since it's part
> of uapi, make sure we don't introduce holes in structs.
> 
> Therefore, add tunnel_ext that we can use generically in future
> (f.e. to flag OAM messages for backends, etc). Also add the offset
> to the compat tests to be sure should some compilers not padd the
> tail of the old version of bpf_tunnel_key.
> 
> Fixes: 4018ab1875e0 ("bpf: support flow label for bpf_skb_{set, get}_tunnel_key")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
