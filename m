From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix regression on verifier pruning wrt map
 lookups
Date: Sat, 17 Dec 2016 10:51:57 -0500 (EST)
Message-ID: <20161217.105157.1777770626254774920.davem@davemloft.net>
References: <fb7031038adc3b04973c8484ba4e9d7aa250cb32.1481761253.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, jbacik@fb.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752560AbcLQPv7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:51:59 -0500
In-Reply-To: <fb7031038adc3b04973c8484ba4e9d7aa250cb32.1481761253.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 15 Dec 2016 01:30:06 +0100

> Commit 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL
> registers") introduced a regression where existing programs stopped
> loading due to reaching the verifier's maximum complexity limit,
> whereas prior to this commit they were loading just fine; the affected
> program has roughly 2k instructions.
> 
> What was found is that state pruning couldn't be performed effectively
> anymore due to mismatches of the verifier's register state, in particular
> in the id tracking. It doesn't mean that 57a09bf0a416 is incorrect per
> se, but rather that verifier needs to perform a lot more work for the
> same program with regards to involved map lookups.
 ...
> Fixes: 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.
