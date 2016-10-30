From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 2/2] geneve: avoid using stale geneve socket.
Date: Sat, 29 Oct 2016 20:56:50 -0400 (EDT)
Message-ID: <20161029.205650.1841065930703303916.davem@davemloft.net>
References: <1477673956-127319-1-git-send-email-pshelar@ovn.org>
        <1477673956-127319-2-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753772AbcJ3A4v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 20:56:51 -0400
In-Reply-To: <1477673956-127319-2-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Fri, 28 Oct 2016 09:59:16 -0700

> This patch is similar to earlier vxlan patch.
> Geneve device close operation frees geneve socket. This
> operation can race with geneve-xmit function which
> dereferences geneve socket. Following patch uses RCU
> mechanism to avoid this situation.
> 
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
> Acked-by: John W. Linville <linville@tuxdriver.com>

Applied.
