From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 3/4] net-next: dsa: Add support for multiple cpu ports.
Date: Wed, 4 Jan 2017 16:22:19 +0100
Message-ID: <20170104152219.GD5517@lunn.ch>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
 <1483515484-21793-4-git-send-email-john@phrozen.org>
 <20170104140105.GL10768@lunn.ch>
 <5a5c86c6-7a19-8720-7772-3d2d5b2633c5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42961 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751505AbdADPXE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 10:23:04 -0500
Content-Disposition: inline
In-Reply-To: <5a5c86c6-7a19-8720-7772-3d2d5b2633c5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I am actually in the process of cleaning up my patches that add
> platform_data support to net/dsa/dsa2.c this time with an user, and
> hopefully a couple more after that, but that maintains the existing
> struct dsa_chip_data as-is, no new additions are required, and this
> would be purely for non-DT enabled platforms anyway.

Hi Florian

I was hoping we could avoid this complexity. But if there is a real
need, the platform cannot be converted to device tree, we can add it.

	Andrew
