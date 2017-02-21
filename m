From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnl: simplify error return path in rtnl_create_link()
Date: Tue, 21 Feb 2017 12:19:44 -0500 (EST)
Message-ID: <20170221.121944.270327711690814852.davem@davemloft.net>
References: <20170220153206.23498-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753907AbdBURTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:19:46 -0500
In-Reply-To: <20170220153206.23498-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Mon, 20 Feb 2017 16:32:06 +0100

> There is only one possible error path which reaches the err label, so
> return ERR_PTR(-ENOMEM) directly if alloc_netdev_mqs() fails. This also
> allows to omit the err variable.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
