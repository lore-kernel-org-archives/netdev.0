From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 6/7] bpf: Make use of alignment information in
 check_val_ptr_alignment().
Date: Thu, 11 May 2017 13:23:54 -0400 (EDT)
Message-ID: <20170511.132354.1049312079662884972.davem@davemloft.net>
References: <20170511.120608.248672395765712270.davem@davemloft.net>
        <59149629.4090109@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932444AbdEKRX4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 13:23:56 -0400
In-Reply-To: <59149629.4090109@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 11 May 2017 18:49:45 +0200

> This actually won't work, see also commit 79adffcd6489 ("bpf,
> verifier:
> fix rejection of unaligned access checks for map_value_adj") with some
> longer explanation. In case of map_value_adj, reg->id is always 0.

I see....

Ok if I merge in the first 5 patches then?

I'll look more deeply into the MAP value issues.
