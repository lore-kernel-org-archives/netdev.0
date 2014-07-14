From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Mon, 14 Jul 2014 15:05:13 -0700 (PDT)
Message-ID: <20140714.150513.1524175237353581279.davem@davemloft.net>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ogerlitz@mellanox.com, linux@stwm.de,
	netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756749AbaGNWFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:05:16 -0400
In-Reply-To: <1405262780-20232-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Sun, 13 Jul 2014 07:46:20 -0700

> From: Jerry Chu <hkchu@google.com>
> 
> Fixed a bug that was introduced by my GRE-GRO patch
> (bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
> support to the GRO stack) that breaks the forwarding path
> because various GSO related fields were not set. The bug will
> cause on the egress path either the GSO code to fail, or a
> GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
> fix has been tested for both cases.
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>

As a regression fix, this should be targetted at 'net' rather than
'net-next' so I can queue it up for -stable too.

Thanks.
