From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sctp: Add peeloff-flags socket option
Date: Sat, 01 Jul 2017 15:26:31 -0700 (PDT)
Message-ID: <20170701.152631.693482856748972097.davem@davemloft.net>
References: <20170629181340.12423-1-nhorman@tuxdriver.com>
        <20170630173257.18990-1-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        vyasevich@gmail.com, ast@domdv.de, marcelo.leitner@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751934AbdGAW0d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 18:26:33 -0400
In-Reply-To: <20170630173257.18990-1-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 30 Jun 2017 13:32:57 -0400

> Based on a request raised on the sctp devel list, there is a need to
> augment the sctp_peeloff operation while specifying the O_CLOEXEC and
> O_NONBLOCK flags (simmilar to the socket syscall).  Since modifying the
> SCTP_SOCKOPT_PEELOFF socket option would break user space ABI for existing
> programs, this patch creates a new socket option
> SCTP_SOCKOPT_PEELOFF_FLAGS, which accepts a third flags parameter to
> allow atomic assignment of the socket descriptor flags.
> 
> Tested successfully by myself and the requestor
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next, thanks Neil.
