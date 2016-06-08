From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v4 5/6] net: dsa: Initialize CPU port ethtool
 ops per tree
Date: Wed, 8 Jun 2016 17:09:35 +0200
Message-ID: <20160608150935.GI28994@lunn.ch>
References: <1465342363-28055-1-git-send-email-f.fainelli@gmail.com>
 <1465342363-28055-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38978 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497AbcFHPJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2016 11:09:39 -0400
Content-Disposition: inline
In-Reply-To: <1465342363-28055-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 04:32:42PM -0700, Florian Fainelli wrote:
> Now that we can properly support multiple distinct trees in the system,
> using a global variable: dsa_cpu_port_ethtool_ops is getting clobbered
> as soon as the second switch tree gets probed, and we don't want that.
> 
> We need to move this to be dynamically allocated, and since we can't
> really be comparing addresses anymore to determine first time
> initialization versus any other times, just move this to dsa.c and
> dsa2.c where the remainder of the dst/ds initialization happens.
> 
> The operations teardown restores the master netdev's ethtool_ops to its
> original ethtool_ops pointer (typically within the Ethernet driver)
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
