From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: cgroup: annotate pointers in struct cgroup_bpf
 with __rcu
Date: Sat, 17 Dec 2016 11:14:42 -0500 (EST)
Message-ID: <20161217.111442.1376859676569540647.davem@davemloft.net>
References: <20161215095321.10571-1-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org
To: daniel@zonque.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756728AbcLQQOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:14:43 -0500
In-Reply-To: <20161215095321.10571-1-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@zonque.org>
Date: Thu, 15 Dec 2016 10:53:21 +0100

> The member 'effective' in 'struct cgroup_bpf' is protected by RCU.
> Annotate it accordingly to squelch a sparse warning.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>

Applied.
