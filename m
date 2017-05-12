From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: add default case to switch
Date: Fri, 12 May 2017 12:15:04 -0400 (EDT)
Message-ID: <20170512.121504.1955818908238157662.davem@davemloft.net>
References: <20170511214814.Horde.otwLVFIaWFNJZ23PSdgsq_Z@gator4166.hostgator.com>
        <20170512031129.GA4065@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170512031129.GA4065@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 11 May 2017 22:11:29 -0500

> Add default case to switch in order to avoid any chance of using an
> uninitialized variable _low_, in case s->type does not match any of
> the listed case values.
> 
> Addresses-Coverity-ID: 1398130
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Applied, thanks.
