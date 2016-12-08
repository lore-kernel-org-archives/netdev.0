From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ll_temac: Utilize of_get_mac_address()
Date: Thu, 08 Dec 2016 11:34:16 -0500 (EST)
Message-ID: <20161208.113416.1295905604443806181.davem@davemloft.net>
References: <20161207122529.29508-1-tklauser@distanz.ch>
        <20161207122529.29508-2-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, f.fainelli@gmail.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753013AbcLHQeS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 11:34:18 -0500
In-Reply-To: <20161207122529.29508-2-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Wed,  7 Dec 2016 13:25:29 +0100

> Do not open code getting the MAC address exclusively from the
> "local-mac-address" property, but instead use of_get_mac_address()
> which looks up the MAC address using the 3 typical property names.
> 
> Also avoid casting away the const qualifier of the return value by
> making temac_init_mac_address() take a const void* address.
> 
> Follows commit b34296a9c047 ("net: ethoc: Utilize
> of_get_mac_address()").
> 
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
