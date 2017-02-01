From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 2/8] net/mlx5: Configure cache line size for start
 and end padding
Date: Wed, 1 Feb 2017 11:12:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0277BC4@AcuExch.aculab.com>
References: <20170131205843.23235-1-saeedm@mellanox.com>
 <20170131205843.23235-3-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Daniel Jurgens <danielj@mellanox.com>
To: 'Saeed Mahameed' <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:58547 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdBALNB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 06:13:01 -0500
In-Reply-To: <20170131205843.23235-3-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed
> Sent: 31 January 2017 20:59
> From: Daniel Jurgens <danielj@mellanox.com>
> 
> There is a hardware feature that will pad the start or end of a DMA to
> be cache line aligned to avoid RMWs on the last cache line. The default
> cache line size setting for this feature is 64B. This change configures
> the hardware to use 128B alignment on systems with 128B cache lines.

What guarantees that the extra bytes are actually inside the receive skb's
head and tail room?

	David
