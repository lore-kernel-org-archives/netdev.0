From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] openvswitch: avoid resetting flow key
 while installing new flow.
Date: Tue, 20 Sep 2016 22:54:52 -0400 (EDT)
Message-ID: <20160920.225452.1951319356915241128.davem@davemloft.net>
References: <1474318260-16988-1-git-send-email-pshelar@ovn.org>
        <1474318260-16988-2-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753824AbcIUCyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:54:54 -0400
In-Reply-To: <1474318260-16988-2-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Mon, 19 Sep 2016 13:51:00 -0700

> since commit commit db74a3335e0f6 ("openvswitch: use percpu
> flow stats") flow alloc resets flow-key. So there is no need
> to reset the flow-key again if OVS is using newly allocated
> flow-key.
> 
> Signed-off-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
