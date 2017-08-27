From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Sun, 27 Aug 2017 15:59:09 +0200
Message-ID: <20170827135909.GF13622@lunn.ch>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45437 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751651AbdH0N7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 09:59:16 -0400
Content-Disposition: inline
In-Reply-To: <20170827123658.GA727@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 27, 2017 at 02:36:58PM +0200, Pavel Machek wrote:
> Hi!
> 
> So I fought with the driver a bit more, and now I have something that
> kind-of-works.


Thanks for keeping on working on this.
 
> "great great hack" belows worries me.
> 
> Yeah, disabled code needs to be removed before merge.
> 
> No, tag_ksz part probably is not acceptable. Do you see solution
> better than just copying it into tag_ksz1 file?
> 
> Any more comments, etc?

It would help with review if you split this up into multiple patches.
The change to the tagger should be one patch. The mdio emulation would
make a reasonable standalone patch etc.

I will do a more detailed review later.

  Andrew
