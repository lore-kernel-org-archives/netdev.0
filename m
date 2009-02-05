From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] cxgb3 - Fix lro switch
Date: Wed, 04 Feb 2009 16:32:50 -0800 (PST)
Message-ID: <20090204.163250.127196315.davem@davemloft.net>
References: <20090205002547.26126.47373.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, kxie@chelsio.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33986
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754383AbZBEAcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 19:32:54 -0500
In-Reply-To: <20090205002547.26126.47373.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 04 Feb 2009 16:25:47 -0800

> The LRO switch is always set to 1 in the rx processing loop.
> It breaks the accelerated iSCSI receive traffic.
> Fix its computation.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied, thank you.

Could you slightly reformat your Subject lines for patches?  Please
use something like "cxgb3: $(description)" instead of the "cxgb3 -
$(description)" you're using now.

It'll be one less thing I need to edit when applying your
patches :-)

Thanks!
