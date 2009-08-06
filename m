From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] documentation: fix wrt. headers rename
Date: Wed, 05 Aug 2009 20:22:26 -0700 (PDT)
Message-ID: <20090805.202226.24204308.davem@davemloft.net>
References: <1249457297-8355-2-git-send-email-dbaryshkov@gmail.com>
	<1249457297-8355-3-git-send-email-dbaryshkov@gmail.com>
	<1249457297-8355-4-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753867AbZHFDWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 23:22:18 -0400
In-Reply-To: <1249457297-8355-4-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Wed,  5 Aug 2009 11:28:17 +0400

> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

What are you generating these patches against?

> @@ -72,5 +72,4 @@ SoftMAC
>  We are going to provide intermediate layer implementing IEEE 802.15.4 MAC
>  in software. This is currently WIP.
>  
> -See header include/net/ieee802154/mac802154.h and several drivers in
> -drivers/ieee802154/
> +See header include/net/mac802154.h and several drivers in drivers/ieee802154/.

In net-2.6, and in Linus's tree as well, that first sentence quoted has
a typo, "implementing" is misspelled, but in whatever you're patching
against the misspelling is fixed.

Looking at your pull request:

--------------------
The following changes since commit db71789c01ae7b641f83c5aa64e7df25122f4b28:
  David S. Miller (1):
        xfrm6: Fix xfrm6_policy.c build when SYSCTL disabled.
--------------------

You're submitting these for net-next-2.6?  Didn't we just go back and
forth about trimming this patch series down to only pure bug fixes so
that they could go into net-2.6?  Given that, why are you generating
this stuff against net-next-2.6?

I'm tossing this entire series again, this is beyond frustrating.
