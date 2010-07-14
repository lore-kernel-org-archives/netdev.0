From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] Removing dead NETWINDER_{T,R}X_DMA_PROBLEMS
Date: Wed, 14 Jul 2010 13:43:19 -0700 (PDT)
Message-ID: <20100714.134319.112602083.davem@davemloft.net>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<48e9743a02fc6630900d911d377002cbd1acb06e.1279110895.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, akpm@linux-foundation.org, roel.kluin@gmail.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: siccegge@cs.fau.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41015
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757731Ab0GNUnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:43:04 -0400
In-Reply-To: <48e9743a02fc6630900d911d377002cbd1acb06e.1279110895.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Egger <siccegge@cs.fau.de>
Date: Wed, 14 Jul 2010 14:41:26 +0200

> NETWINDER_{T,R}X_DMA_PROBLEMS doesn't exist in Kconfig, therefore
> removing all references for it from the source code.
> 
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

It is getting set by hand in the driver, which is undesirable but you
can't just kill this stuff off like this.  You have to move the
settings into the appropriate Kconfig location.

I'm not applying this patch.
