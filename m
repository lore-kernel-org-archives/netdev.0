From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports
 for bridging device
Date: Tue, 24 Mar 2009 23:40:51 -0700 (PDT)
Message-ID: <20090324.234051.60226102.davem@davemloft.net>
References: <1237539869-30721-1-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47904
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753134AbZCYGlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:41:05 -0400
In-Reply-To: <1237539869-30721-1-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Yang <leoli@freescale.com>
Date: Fri, 20 Mar 2009 17:04:29 +0800

> The bridging device used a constant hard_header_len.  This will cause
> headroom shortage for ports with additional hardware header.  The patch
> makes bridging device to use the maximum value of all ports.
> 
> Signed-off-by: Li Yang <leoli@freescale.com>

Your driver must be able to cope with any amount of
available headroom, no matter what hacks we put into
the bridging layer.

Please fix your driver, I'm not applying this patch.
