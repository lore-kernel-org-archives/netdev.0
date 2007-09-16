From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cleanup calling netdev notifiers
Date: Sun, 16 Sep 2007 15:43:12 -0700 (PDT)
Message-ID: <20070916.154312.91322523.davem@davemloft.net>
References: <46EA63AE.3070100@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:36124
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753244AbXIPWnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 18:43:15 -0400
In-Reply-To: <46EA63AE.3070100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 14 Sep 2007 14:34:22 +0400

> The call_netdev_notifiers routine can successfully be used in
> the net/core_dev.c itself.
> 
> This will save 6 lines of code and 62 ;) bytes of .text section.
> 
> 62 is rather small, but I have one more patch saving ~30 bytes
> from netns code (sent to Eric), so altogether they can save 
> some more noticeable amount.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.24, thanks Pavel.
