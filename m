From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Two BPF fixes
Date: Mon, 17 Apr 2017 15:52:50 -0400 (EDT)
Message-ID: <20170417.155250.1243917459853868743.davem@davemloft.net>
References: <cover.1492390940.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753761AbdDQTwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:52:51 -0400
In-Reply-To: <cover.1492390940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 17 Apr 2017 03:12:05 +0200

> The set fixes cb_access and xdp_adjust_head bits in struct bpf_prog,
> that are used for requirement checks on the program rather than f.e.
> heuristics. Thus, for tail calls, we cannot make any assumptions and
> are forced to set them.

Series applied, thanks.

Tail calls bring up all kinds of caching and assumption issues, see my
question in another thread about how register cached SKB parameters
are handled in JITs across tail calls.
