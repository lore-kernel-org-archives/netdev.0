From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 17:31:38 +0200
Message-ID: <1341934298.3265.5514.camel@edumazet-glaptop>
References: <20120710.080714.2272376193166978850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39372 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577Ab2GJPbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:31:42 -0400
Received: by eaak11 with SMTP id k11so55552eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:31:41 -0700 (PDT)
In-Reply-To: <20120710.080714.2272376193166978850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 08:07 -0700, David Miller wrote:
> Maintain a local hash table of TCP dynamic metrics blobs.
> 
> Computed TCP metrics are no longer maintained in the route metrics.
> 
> The table uses RCU and an extremely simple hash so that it has low
> latency and low overhead.  A simple hash is legitimate because we only
> make metrics blobs for fully established connections.
> 
> Some tweaking of the default hash table sizes, metric timeouts, and
> the hash chain length limit certainly could use some tweaking.  But
> the basic design seems sound.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Seems to lack namespace support, or maybe I missed something ?
