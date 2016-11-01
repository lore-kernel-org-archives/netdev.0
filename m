From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/11] net: dsa: mv88e6xxx: add port link setter
Date: Tue, 1 Nov 2016 10:43:13 +0100
Message-ID: <20161101094313.GB2802@lunn.ch>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com>
 <20161101032023.32762-8-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59665 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1422927AbcKAJnP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 05:43:15 -0400
Content-Disposition: inline
In-Reply-To: <20161101032023.32762-8-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define LINK_UNKNOWN	-1
> +
> +	/* Port's MAC link state
> +	 * LINK_UNKNOWN for normal link detection, 0 to force link down,
> +	 * otherwise force link up.
> +	 */
> +	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);

Hi Vivien

Maybe LINK_AUTO would be better than UNKNOWN? Or LINK_UNFORCED.

      Andrew
