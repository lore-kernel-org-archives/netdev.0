From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some
 warnings on Blackfin
Date: Mon, 13 Oct 2008 03:01:50 -0700 (PDT)
Message-ID: <20081013.030150.96524866.davem@davemloft.net>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@simtec.co.uk, s.hauer@pengutronix.de, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jherrero@hvsistemas.es
To: cooloney@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763436AbYJMKCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 06:02:14 -0400
In-Reply-To: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan Wu <cooloney@kernel.org>
Date: Mon, 13 Oct 2008 17:10:09 +0800

> From: Javier Herrero <jherrero@hvsistemas.es>
> 
> Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

This is not only inelegant, it'll likely break things on
64-bit MIPS or any other case where the upper 32-bit matter.

I'd rather see Blackfin fix it's I/O accessor prototypes
to take a proper __iomem pointer.

This patch won't be applied.
