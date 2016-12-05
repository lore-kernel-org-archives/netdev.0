From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next 2/3] net: ethoc: Utilize of_get_mac_address()
Date: Mon, 5 Dec 2016 08:20:39 +0100
Message-ID: <20161205072039.GC22467@distanz.ch>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
 <20161204204030.9853-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:57373 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751120AbcLEHUt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 02:20:49 -0500
Content-Disposition: inline
In-Reply-To: <20161204204030.9853-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-04 at 21:40:29 +0100, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Do not open code getting the MAC address exclusively from the
> "local-mac-address" property, but instead use of_get_mac_address() which
> looks up the MAC address using the 3 typical property names.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
