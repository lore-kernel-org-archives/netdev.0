From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic with
 DSA
Date: Mon, 9 Jan 2017 22:23:20 +0100
Message-ID: <20170109212320.GB20958@lunn.ch>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109204849.GA28310@splinter>
 <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
 <20170109211436.GB28310@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53485 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031130AbdAIVXX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 16:23:23 -0500
Content-Disposition: inline
In-Reply-To: <20170109211436.GB28310@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Truth be told, I don't quite understand why switchdev infra even tries
> to dump the VLANs from the device. Like, in which situations is this
> going to be different from what the software bridge reports?

What happens when the hardware is out of resources and says sorry,
cannot do that. There has been a few discussions about what to do in
that situation. Fall back to software, i.e. the software bridge does
it, or totally fail the operation. If you are failing back to
software, the states can be different.

    Andrew
