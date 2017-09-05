From: David Miller <davem@davemloft.net>
Subject: Re: [net v2] gianfar: Fix Tx flow control deactivation
Date: Tue, 05 Sep 2017 14:35:43 -0700 (PDT)
Message-ID: <20170905.143543.1026660660946884756.davem@davemloft.net>
References: <1504511128-25294-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752145AbdIEVfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:35:44 -0400
In-Reply-To: <1504511128-25294-1-git-send-email-claudiu.manoil@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@nxp.com>
Date: Mon, 4 Sep 2017 10:45:28 +0300

> The wrong register is checked for the Tx flow control bit,
> it should have been maccfg1 not maccfg2.
> This went unnoticed for so long probably because the impact is
> hardly visible, not to mention the tangled code from adjust_link().
> First, link flow control (i.e. handling of Rx/Tx link level pause frames)
> is disabled by default (needs to be enabled via 'ethtool -A').
> Secondly, maccfg2 always returns 0 for tx_flow_oldval (except for a few
> old boards), which results in Tx flow control remaining always on
> once activated.
> 
> Fixes: 45b679c9a3ccd9e34f28e6ec677b812a860eb8eb ("gianfar: Implement PAUSE frame generation support")
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>

Please do not put an empty line between Fixes: and other tags.  All tags
are equal and should be in one uninterrupted block of text.

Applied, and queued up for -stable, thanks.
