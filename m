From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink/diag: report flags for netlink sockets
Date: Wed, 05 Apr 2017 07:14:11 -0700 (PDT)
Message-ID: <20170405.071411.2298343752885964778.davem@davemloft.net>
References: <20170404011332.13469-1-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754268AbdDEOOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 10:14:15 -0400
In-Reply-To: <20170404011332.13469-1-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@openvz.org>
Date: Mon,  3 Apr 2017 18:13:32 -0700

> From: Andrey Vagin <avagin@openvz.org>
> 
> cb_running is reported in /proc/self/net/netlink and it is reported by
> the ss tool, when it gets information from the proc files.
> 
> sock_diag is a new interface which is used instead of proc files, so it
> looks reasonable that this interface has to report no less information
> about sockets than proc files.
> 
> We use these flags to dump and restore netlink sockets.
> 
> Signed-off-by: Andrei Vagin <avagin@openvz.org>

Ok, applied, thanks Andrei.
