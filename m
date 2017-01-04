From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next v1] ipvlan: assign unique dev-id for each slave
 device.
Date: Wed, 04 Jan 2017 13:30:53 -0500 (EST)
Message-ID: <20170104.133053.1438331328167852153.davem@davemloft.net>
References: <20170103204716.9436-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758806AbdADScb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 13:32:31 -0500
In-Reply-To: <20170103204716.9436-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Tue,  3 Jan 2017 12:47:16 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> IPvlan setup uses one mac-address (of master). The IPv6 link-local
> addresses are derived using the mac-address on the link. Lack of
> dev-ids makes these link-local addresses same for all slaves including
> that of master device. dev-ids are necessary to add differentiation
> when L2 address is shared.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
