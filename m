From: David Miller <davem@davemloft.net>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Mon, 19 Jul 2010 09:05:03 -0700 (PDT)
Message-ID: <20100719.090503.73693858.davem@davemloft.net>
References: <20100719101904.GA31743@redhat.com>
	<20100719105300.GA22179@gondor.apana.org.au>
	<20100719115411.GA22758@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, shemminger@vyatta.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37021
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936201Ab0GSQEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 12:04:47 -0400
In-Reply-To: <20100719115411.GA22758@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Jul 2010 19:54:11 +0800

> Still, it might be a good idea to disable bridge netpoll in
> 2.6.35.

I thought we did that already.... oh I see, we did it for bonding:

commit c22d7ac844f1cb9c6a5fd20f89ebadc2feef891b
Author: Andy Gospodarek <andy@greyhouse.net>
Date:   Fri Jun 25 09:50:44 2010 +0000

    bonding: prevent netpoll over bonded interfaces

I'm fine with disabling it for bridging too, just send me a patch
similar to the bonding one.
