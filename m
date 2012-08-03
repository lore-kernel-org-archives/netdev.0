From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH 0/4] net/mlx4: Fixes to mlx4 driver
Date: Fri, 3 Aug 2012 07:20:50 +0000
Message-ID: <953B660C027164448AE903364AC447D2871F0C73@MTLDAG01.mtl.com>
References: <1343921456-19180-1-git-send-email-yevgenyp@mellanox.co.il>
 <20120802.161251.331601378090436432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:50214 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751167Ab2HCHU7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2012 03:20:59 -0400
In-Reply-To: <20120802.161251.331601378090436432.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > Yevgeny Petrilin (3):
> >   net/mlx4_en: Setting the NETIF_F_GRO flag back to dev->hw_features
> 
> As pointed out, this isn't a bug.
> 
> You just made this change purely via code inspection, and that's very
> disappointing because this would have been so simple to validate.
 
Hello Dave,
You are absolutely right,
I should have checked it better.
There are few more modules setting this flag during device initialization, I guess we need to clean all.

Can you please apply the other 3 or should I resubmit them?

Thanks,
Yevgeny
