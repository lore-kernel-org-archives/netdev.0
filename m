From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] sfc: separate out SFC4000 ("Falcon")
 support into new sfc-falcon driver
Date: Wed, 30 Nov 2016 10:18:21 -0500 (EST)
Message-ID: <20161130.101821.802133826107860380.davem@davemloft.net>
References: <624b8ce9-12dd-1b89-ae9f-8a092751bf12@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, bkenward@solarflare.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbcK3PSX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:18:23 -0500
In-Reply-To: <624b8ce9-12dd-1b89-ae9f-8a092751bf12@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied, but yes you should really rethink the Kconfig stuff.

I would strongly suggest you simply make them independent Kconfig
options with no attachment to eachother.  No depends, no implies,
nothing like that.
