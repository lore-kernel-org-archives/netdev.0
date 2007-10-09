From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Don't memset() netns to zero manually
Date: Tue, 09 Oct 2007 13:02:37 -0700 (PDT)
Message-ID: <20071009.130237.122618431.davem@davemloft.net>
References: <470B6A83.8070600@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39967
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753038AbXJIUCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:02:42 -0400
In-Reply-To: <470B6A83.8070600@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 09 Oct 2007 15:48:19 +0400

> The newly created net namespace is set to 0 with memset()
> in setup_net(). The setup_net() is also called for the
> init_net_ns(), which is zeroed naturally as a global var.
> 
> So remove this memset and allocate new nets with the
> kmem_cache_zalloc().
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel!
