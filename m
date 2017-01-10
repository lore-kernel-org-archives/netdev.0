From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: Implement ndo_get_phys_port_name()
Date: Tue, 10 Jan 2017 21:50:43 +0100
Message-ID: <20170110205043.GM22820@lunn.ch>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
 <20170110203237.23907-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54490 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751155AbdAJUuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 15:50:46 -0500
Content-Disposition: inline
In-Reply-To: <20170110203237.23907-2-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 12:32:36PM -0800, Florian Fainelli wrote:
> Return the physical port number of a DSA created network device using
> ndo_get_phys_port_name().

At what level does this need to be unique?

We can have multiple switches within one switch cluster. p->port will
be unique within one switch, but can be repeated in a cluster.

We can also have multiple clusters, and again p->port will be re-used.

   Andrew
