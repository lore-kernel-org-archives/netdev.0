From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATC net-next] tcp: must block bh in __inet_twsk_hashdance()
Date: Wed, 04 May 2016 15:21:19 -0700
Message-ID: <1462400479.13075.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462320650.5535.334.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160504.005450.32648328658519474.davem@davemloft.net>
	 <1462386131.5535.353.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160504.170641.134283593327091145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34574 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbcEDWVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 18:21:22 -0400
Received: by mail-pa0-f54.google.com with SMTP id r5so29459459pag.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 15:21:22 -0700 (PDT)
In-Reply-To: <20160504.170641.134283593327091145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 17:06 -0400, David Miller wrote:

> I pushed them in by hand, they should really be there now.
> 
> Thanks for letting me know.

Thanks David

Further tests show two additional missing local_bh_disable() protections
around percpu_counter_dec() and one sk_sockets_allocated_dec()

Will send the patch in few minutes.
