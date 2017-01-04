From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 2/4] net-next: dsa: Refactor DT probing of a switch port
Date: Wed, 4 Jan 2017 14:30:31 +0100
Message-ID: <20170104133031.GI10768@lunn.ch>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
 <1483515484-21793-3-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42863 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757882AbdADNag (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 08:30:36 -0500
Content-Disposition: inline
In-Reply-To: <1483515484-21793-3-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 08:38:02AM +0100, John Crispin wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> 
> Move the DT probing of a switch port into a function of its own, since
> it is about to get more complex. Add better error handling as well.

Hi John

I would prefer to drop the majority of this. Just keep enough that it
does not break, but don't implement multiple CPU ports.

     Andrew
