From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY
 ID on mv88e6390
Date: Wed, 25 Jan 2017 18:52:45 +0100
Message-ID: <20170125175245.GB6611@lunn.ch>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
 <1485309314-23942-2-git-send-email-andrew@lunn.ch>
 <87sho7123x.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45890 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751016AbdAYRws (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 12:52:48 -0500
Content-Disposition: inline
In-Reply-To: <87sho7123x.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I tested this series on the Topaz switch but it failed because while I
> said we read 0x1410C00 actually we read 0x01410C01. With the
> MARVELL_PHY_ID_MASK we mask the 4 lower bits so that's why in my patch
> "phy: marvell: Add support for the PHY embedded in the topaz switch" I
> used the 0x01410C00 value for MARVELL_PHY_ID_88E6141.

O.K. The lower 4 bits seem to be the silicon revision. Marvells own
SDK ignores those bits. So lets do the same here, use
MARVELL_PHY_ID_MASK.

	Andrew
