From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 05/11] net: dsa: mv88e6xxx: Add comment about
 family a device belongs to
Date: Mon, 14 Nov 2016 03:48:52 +0100
Message-ID: <20161114024852.GA26710@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
 <1478832823-31471-6-git-send-email-andrew@lunn.ch>
 <8737iubype.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37330 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936565AbcKNCtC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 21:49:02 -0500
Content-Disposition: inline
In-Reply-To: <8737iubype.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 01:08:13PM +1100, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > Knowing the family of device belongs to helps with picking the ops
> > implementation which is appropriate to the device. So add a comment to
> > each structure of ops.
> 
> This commit is not necessary. mv88e6xxx_ops structure must be per-chip,
> and the family information is already described in patch 03/11.

I disagree. I made a lot of errors adding the right per family handler
to these structures, simply because it is not obvious what family a
device belongs to when looking at the structure.

       Andrew
