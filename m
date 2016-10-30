From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 1/2] vxlan: avoid using stale vxlan socket.
Date: Sat, 29 Oct 2016 20:56:43 -0400 (EDT)
Message-ID: <20161029.205643.527711053369155352.davem@davemloft.net>
References: <1477673956-127319-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753772AbcJ3A4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 20:56:45 -0400
In-Reply-To: <1477673956-127319-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Fri, 28 Oct 2016 09:59:15 -0700

> When vxlan device is closed vxlan socket is freed. This
> operation can race with vxlan-xmit function which
> dereferences vxlan socket. Following patch uses RCU
> mechanism to avoid this situation.
> 
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
