From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Thu, 06 Sep 2007 04:02:35 -0700 (PDT)
Message-ID: <20070906.040235.71121480.davem@davemloft.net>
References: <1189022828.4960.2.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:59494
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751008AbXIFLCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 07:02:40 -0400
In-Reply-To: <1189022828.4960.2.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 05 Sep 2007 13:07:08 -0700

> [TG3]: Workaround MSI bug on 5714/5780.
> 
> A hardware bug was revealed after a recent PCI MSI patch was made to
> always disable legacy INTX when enabling MSI.  The 5714/5780 chips
> will not generate MSI when INTX is disabled, causing MSI failure
> messages to be reported, and another patch was made to workaround the
> problem by disabling MSI on ServerWorks HT1000 bridge chips commonly
> found with the 5714.
> 
> We workaround this chip bug by enabling INTX after we enable MSI and
> after we resume from suspend.
> 
> Update version to 3.81.
> 
> This problem was discovered by David Miller.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Thanks a lot Michael, I'll apply this and work on reverting that
incorrect MSI chipset quirk too.
