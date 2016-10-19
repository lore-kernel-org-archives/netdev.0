From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fs_enet: Use net_device_stats from struct
 net_device
Date: Wed, 19 Oct 2016 10:37:19 -0400 (EDT)
Message-ID: <20161019.103719.1662715158720899418.davem@davemloft.net>
References: <20161019092457.15006-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942433AbcJSOhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:37:21 -0400
In-Reply-To: <20161019092457.15006-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed, 19 Oct 2016 11:24:57 +0200

> Instead of using a private copy of struct net_device_stats in struct
> fs_enet_private, use stats from struct net_device. Also remove the now
> unnecessary .ndo_get_stats function.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied to net-next, thanks.
