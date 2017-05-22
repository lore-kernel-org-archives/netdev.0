From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bridge: fix hello and hold timers
 starting/stopping
Date: Mon, 22 May 2017 14:41:30 -0400 (EDT)
Message-ID: <20170522.144130.1968086500919533289.davem@davemloft.net>
References: <20170519173043.10201-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        lucien.xin@gmail.com, nikolay@cumulusnetworks.com
To: cera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760909AbdEVSlc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:41:32 -0400
In-Reply-To: <20170519173043.10201-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <cera@cera.cz>
Date: Fri, 19 May 2017 19:30:43 +0200

> Current bridge code incorrectly handles starting/stopping of hello and
> hold timers during STP enable/disable.
> 
> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
>    transition. The timers are already stopped in NO_STP state so
>    this is confusing no-op.
> 
> 2. During USER_STP->NO_STP transition the timers are started. This
>    does not make sense and is confusion because the timer should not be
>    active in NO_STP state.
> 
> Cc: davem@davemloft.net
> Cc: sashok@cumulusnetworks.com
> Cc: stephen@networkplumber.org
> Cc: bridge@lists.linux-foundation.org
> Cc: lucien.xin@gmail.com
> Cc: nikolay@cumulusnetworks.com
> Signed-off-by: Ivan Vecera <cera@cera.cz>

Applied.
