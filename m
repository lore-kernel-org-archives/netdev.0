From: Jochen Friedrich <jochen@scram.de>
Subject: Re: [PATCH] powerpc: Fix fs_enet module build
Date: Wed, 14 Nov 2007 12:59:33 +0100
Message-ID: <473AE325.8070901@scram.de>
References: <4739EDA8.6020800@scram.de> <20071113.210926.97725854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-embedded@ozlabs.org, marcelo@kvack.org,
	scottwood@freescale.com, linux-kernel@vger.kernel.org,
	jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail0.scram.de ([78.47.204.202]:60624 "EHLO mail0.scram.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194AbXKNMAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 07:00:09 -0500
In-Reply-To: <20071113.210926.97725854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

> This is truly ugly and creates an unnecessarily hard to
> maintain and complex driver.
> 
> Please find a way to fix this for real, so that the
> PPC_CPM_NEW_BINDING ifdef is not necessary at all and
> things get built modular or not naturally as we handle
> things for other cases like this.

I know it's ugly, however, module building is completely
broken right now and I just want to provide a quick and
ugly fix until both that ppc->powerpc transition and the
new binding transition are over. Noone wants to touch the
old stuff any more as it's a pita and it's already scheduled
for removal in a couple of months.

Thanks,
Jochen
