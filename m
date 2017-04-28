From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 18/18] net: dsa: mv88e6xxx: add VTU support for
 88E6390
Date: Fri, 28 Apr 2017 14:55:28 +0200
Message-ID: <20170428125528.GL13231@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-19-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44422 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2993823AbdD1Mza (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 08:55:30 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-19-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:36AM -0400, Vivien Didelot wrote:
> The 6390 family of chips use only 2 of the 3 VTU Data registers to pack
> the MemberTag and PortState VLAN data. This means that they must be
> written or read before or after each VTU/STU operations.
> 
> Implement this variant to add support for VTU with such chips. These
> chips have a 13th bit for the VID thus set their max_vid to 8191.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
