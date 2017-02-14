From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make net_device members garp_port and
 mrp_port conditional
Date: Mon, 13 Feb 2017 22:03:32 -0500 (EST)
Message-ID: <20170213.220332.1254193563682425809.davem@davemloft.net>
References: <20170210154350.11694-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdBNDDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 22:03:35 -0500
In-Reply-To: <20170210154350.11694-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 10 Feb 2017 16:43:50 +0100

> garp_port is only used in net/802/garp.c which is only compiled with
> CONFIG_GARP enabled. Same goes for mrp_port which is only used in
> net/802/mrp.c with CONFIG_MRP enabled.
> 
> Only include the two members in struct net_device if their respective
> CONFIG_* is enabled. This saves a few bytes in struct net_device in case
> CONFIG_GARP or CONFIG_MRP are not enabled.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
