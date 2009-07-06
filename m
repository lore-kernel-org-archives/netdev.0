From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: fix 88e6xxx statistics counter snapshotting
Date: Sun, 05 Jul 2009 19:03:40 -0700 (PDT)
Message-ID: <20090705.190340.26255337.davem@davemloft.net>
References: <20090703092648.GM19647@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	Stephane.Contri@grassvalley.com
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbZGFCDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:03:33 -0400
In-Reply-To: <20090703092648.GM19647@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Fri, 3 Jul 2009 11:26:48 +0200

> From: Stephane Contri <Stephane.Contri@grassvalley.com>
> 
> The bit that tells us whether a statistics counter snapshot operation
> has completed is located in the GLOBAL register block, not in the
> GLOBAL2 register block, so fix up mv88e6xxx_stats_wait() to poll the
> right register address.
> 
> Signed-off-by: Stephane Contri <Stephane.Contri@grassvalley.com>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, and queued up for -stable.
