From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: korina: Fix NAPI versus resources freeing
Date: Mon, 26 Dec 2016 11:26:36 -0500 (EST)
Message-ID: <20161226.112636.2130782607738208283.davem@davemloft.net>
References: <20161224035656.11289-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex@ozo.com, phil@nwl.cc
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755041AbcLZQ0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 11:26:38 -0500
In-Reply-To: <20161224035656.11289-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 23 Dec 2016 19:56:56 -0800

> Commit beb0babfb77e ("korina: disable napi on close and restart")
> introduced calls to napi_disable() that were missing before,
> unfortunately this leaves a small window during which NAPI has a chance
> to run, yet we just freed resources since korina_free_ring() has been
> called:
> 
> Fix this by disabling NAPI first then freeing resource, and make sure
> that we also cancel the restart taks before doing the resource freeing.
> 
> Fixes: beb0babfb77e ("korina: disable napi on close and restart")
> Reported-by: Alexandros C. Couloumbis <alex@ozo.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
