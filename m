From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: fix flow disector null pointer
Date: Tue, 15 Aug 2017 17:19:18 -0700 (PDT)
Message-ID: <20170815.171918.489226613083440129.davem@davemloft.net>
References: <20170815134340.169914-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, andrew@lunn.ch, dvyukov@google.com,
        netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44130 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752130AbdHPATT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:19:19 -0400
In-Reply-To: <20170815134340.169914-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 15 Aug 2017 09:43:40 -0400

> From: Craig Gallek <kraig@google.com>
> 
> A recent change to fix up DSA device behavior made the assumption that
> all skbs passing through the flow disector will be associated with a
> device. This does not appear to be a safe assumption.  Syzkaller found
> the crash below by attaching a BPF socket filter that tries to find the
> payload offset of a packet passing between two unix sockets.
 ...
> Fixes: 43e665287f93 ("net-next: dsa: fix flow dissection")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thanks.
