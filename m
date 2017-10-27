From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: Check DSA notifier master
 against ourself
Date: Fri, 27 Oct 2017 22:13:52 +0900 (KST)
Message-ID: <20171027.221352.39794304629035386.davem@davemloft.net>
References: <20171026010105.13931-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752195AbdJ0NN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 09:13:58 -0400
In-Reply-To: <20171026010105.13931-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 25 Oct 2017 18:01:05 -0700

> Check that the master network device that is signaled through the DSA
> notifier is actually going to be ourself, otherwise, we could just be
> de-referencing garbage from other drivers.
> 
> Fixes: 84ff33eeb23d ("net: systemport: Establish DSA network device queue mapping")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
