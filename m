From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do
 802.3x flow control?
Date: Thu, 3 Mar 2016 23:26:54 +0100
Message-ID: <20160303222654.GS15541@lunn.ch>
References: <56D8B83E.7000303@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johan@kernel.org,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49127 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758430AbcCCW05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 17:26:57 -0500
Content-Disposition: inline
In-Reply-To: <56D8B83E.7000303@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 05:18:38PM -0500, Murali Karicheri wrote:
> Hi,
> 
> We are using Micrel Phy in one of our board and wondering if we can force the
> Phy to disable flow control at start. I have a 1G ethernet switch connected
> to Phy and the phy always enable flow control. I would like to configure the
> phy not to flow control. Is that possible and if yes, what should I do in the
> my Ethernet driver to tell the Phy not to enable flow control?

Hi Murali

Have you played with:

       ethtool -a|--show-pause devname

       ethtool -A|--pause devname [autoneg on|off] [rx on|off] [tx on|off]

Andrew
