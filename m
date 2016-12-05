From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next 1/3] net: ethoc: Account for duplex changes
Date: Mon, 5 Dec 2016 08:20:15 +0100
Message-ID: <20161205072014.GB22467@distanz.ch>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
 <20161204204030.9853-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:57356 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751120AbcLEHUi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 02:20:38 -0500
Content-Disposition: inline
In-Reply-To: <20161204204030.9853-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-04 at 21:40:28 +0100, Florian Fainelli <f.fainelli@gmail.com> wrote:
> ethoc_mdio_poll() which is our PHYLIB adjust_link callback does nothing,
> we should at least react to duplex changes and change MODER accordingly.
> Speed changes is not a problem, since the OpenCores Ethernet core seems
> to be reacting okay without us telling it.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
