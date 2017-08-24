From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: netdev is never null in __dev_map_flush
Date: Wed, 23 Aug 2017 22:43:59 -0700 (PDT)
Message-ID: <20170823.224359.1867611342740230547.davem@davemloft.net>
References: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdHXFoA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:44:00 -0400
In-Reply-To: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 24 Aug 2017 03:20:11 +0200

> No need to test for it in fast-path, every dev in bpf_dtab_netdev
> is guaranteed to be non-NULL, otherwise dev_map_update_elem() will
> fail in the first place.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
