From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/11] net: dsa: mv88e6xxx: add port link setter
Date: Wed, 2 Nov 2016 10:16:29 +0100
Message-ID: <20161102091629.GA384@lunn.ch>
References: <20161101032023.32762-1-vivien.didelot@savoirfairelinux.com>
 <20161101032023.32762-8-vivien.didelot@savoirfairelinux.com>
 <20161101094313.GB2802@lunn.ch>
 <87shra4rlu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34036 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754646AbcKBJQd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 05:16:33 -0400
Content-Disposition: inline
In-Reply-To: <87shra4rlu.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 02:07:09AM +0100, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> >> +#define LINK_UNKNOWN	-1
> >> +
> >> +	/* Port's MAC link state
> >> +	 * LINK_UNKNOWN for normal link detection, 0 to force link down,
> >> +	 * otherwise force link up.
> >> +	 */
> >> +	int (*port_set_link)(struct mv88e6xxx_chip *chip, int port, int link);
> >
> > Maybe LINK_AUTO would be better than UNKNOWN? Or LINK_UNFORCED.
> 
> I used LINK_UNKNOWN to be consistent with the supported SPEED_UNKNOWN
> and DUPLEX_UNKNOWN values of PHY devices.

Hi Vivien

These are i think for reporting back to user space what duplex or link
is currently being used. But here you are setting, not
reporting. Setting something to an unknown state is rather odd, and in
fact, it is not unknown, it is unforced.

      Andrew
