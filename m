From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 net-next] tg3: Fix jumbo loopback test on 5719
Date: Sun, 04 Mar 2012 20:39:39 -0500 (EST)
Message-ID: <20120304.203939.1673052107027175260.davem@davemloft.net>
References: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276Ab2CEBjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:39:42 -0500
In-Reply-To: <1330908495-3758-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Sun, 4 Mar 2012 16:48:13 -0800

> Loopback on 9K packet fails because the chip has a DMA limit of 4K.  The
> loopback test logic uses a single BD for simplicity.  Fix it by reducing
> the jumbo packet size to the DMA limit.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Reviewed-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
