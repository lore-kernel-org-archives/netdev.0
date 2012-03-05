From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3 net-next] tg3: Fix poor tx performance on 57766
 after MTU change
Date: Sun, 04 Mar 2012 20:39:51 -0500 (EST)
Message-ID: <20120304.203951.2219807144353946629.davem@davemloft.net>
References: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
	<1330908495-3758-2-git-send-email-mchan@broadcom.com>
	<1330908495-3758-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47531 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756141Ab2CEBjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:39:53 -0500
In-Reply-To: <1330908495-3758-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 4 Mar 2012 16:48:15 -0800

> GRC reset causes the read DMA engine to go into a mode that breaks up
> requests into 256 bytes.  A PHY reset is required to bring it back to
> the normal mode.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
