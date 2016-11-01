From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 08/11] net: dsa: mv88e6xxx: add port duplex
 setter
Date: Tue, 1 Nov 2016 10:44:40 +0100
Message-ID: <20161101094440.GC2802@lunn.ch>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com>
 <20161101032023.32762-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59670 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1168313AbcKAJom (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 05:44:42 -0400
Content-Disposition: inline
In-Reply-To: <20161101032023.32762-9-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
> +
> +	/* Port's MAC duplex mode
> +	 *
> +	 * Use DUPLEX_HALF or DUPLEX_FULL to force half or full duplex, or
> +	 * DUPLEX_UNKNOWN for normal duplex detection.
> +	 */
> +	int (*port_set_duplex)(struct mv88e6xxx_chip *chip, int port, int dup);

Hi Vivien

Again, i think DUPLEX_UNFORCED, or DUPLEX_AUTO would be better.

       Andrew
