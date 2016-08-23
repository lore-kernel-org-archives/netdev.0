From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] dsa: mv88e6xxx: Delete ppu timer when removing module
Date: Tue, 23 Aug 2016 16:10:16 +0200
Message-ID: <20160823141016.GG20029@lunn.ch>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
 <1471874464-16142-4-git-send-email-andrew@lunn.ch>
 <d20478f0-c11a-dfb2-26d0-a65db4119124@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42326 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753728AbcHWQYr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 12:24:47 -0400
Content-Disposition: inline
In-Reply-To: <d20478f0-c11a-dfb2-26d0-a65db4119124@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >+static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
> >+{
> >+	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU)) {
> >+		mv88e6xxx_ppu_state_destroy(chip);
> >+	}
> 
>    {} not needed here. See Documentation/CodingStyle, chapter 3.

Agreed, I will send a follow up patch, since the patchset has been
accepted.

Thanks
	Andrew
