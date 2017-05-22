From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: define PKTINFO timestamping option in
 all archs
Date: Sun, 21 May 2017 23:35:52 -0400 (EDT)
Message-ID: <20170521.233552.1330381397679616478.davem@davemloft.net>
References: <20170522033147.17264-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mlichvar@redhat.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757001AbdEVDfy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 23:35:54 -0400
In-Reply-To: <20170522033147.17264-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Sun, 21 May 2017 23:31:47 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> The newly introduced timestamping option SCM_TIMESTAMPING_PKTINFO
> is defined in asm-generic/socket.h. Also define it in the architecture
> specific versions.
> 
> Fixes: aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> CC: Miroslav Lichvar <mlichvar@redhat.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

I pushed a fix for this about 15 minutes ago :-)
