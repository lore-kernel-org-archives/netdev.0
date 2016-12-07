From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: axienet: Utilize of_get_mac_address()
Date: Wed, 7 Dec 2016 13:31:44 +0100
Message-ID: <20161207123144.GB13408@distanz.ch>
References: <20161207122529.29508-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:32903 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752423AbcLGMbs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 07:31:48 -0500
Content-Disposition: inline
In-Reply-To: <20161207122529.29508-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-07 at 13:25:28 +0100, Tobias Klauser <tklauser@distanz.ch> wrote:
> Do not open code getting the MAC address exclusively from the
> "local-mac-address" property, but instead use of_get_mac_address()
> which looks up the MAC address using the 3 typical property names.
> 
> Also avoid casting away the const qualifier of the return value by
> making axienet_set_mac_address() take a const void* address.
> 
> Follows commit b34296a9c047 ("net: ethoc: Utilize
> of_get_mac_address()").
> 
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Sorry for the duplicate, please disregard this patch.
