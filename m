From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 00/20] net: dsa: distribute switch events
Date: Mon, 22 May 2017 16:48:25 +0200
Message-ID: <20170522144825.GG29447@lunn.ch>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170522.104557.1244582147577060590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39481 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934866AbdEVOs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 10:48:27 -0400
Content-Disposition: inline
In-Reply-To: <20170522.104557.1244582147577060590.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 10:45:57AM -0400, David Miller wrote:
> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Fri, 19 May 2017 17:00:35 -0400
> 
> > DSA is by nature the support for a switch fabric, which can be composed
> > of a single, or multiple interconnected Ethernet switch chips.
> > 
> > The current DSA core behavior is to identify the slave port targeted by
> > a request (e.g. adding a VLAN entry), and program the switch chip to
> > which it belongs accordingly.
> > 
> > This is problematic in a multi-chip environment, since all chips of a
> > fabric must be aware of most configuration changes. Here are some
> > concrete examples in a 3-chip environment:
>  ...
> > This patch series uses the notification chain introduced for bridging,
> > to notify not only bridge, but switchdev attributes and objects events
> > to all switch chips of the fabric.
> 
> Andrew or Florian, can I get a review?

Yes, it is on my TODO list for today/tomorrow.

     Andrew
