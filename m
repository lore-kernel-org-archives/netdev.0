From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 02/18] net: dsa: mv88e6xxx: split VTU entry data
 member
Date: Thu, 27 Apr 2017 20:25:35 +0200
Message-ID: <20170427182535.GD17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43657 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164040AbdD0SZk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 14:25:40 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-3-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:20AM -0400, Vivien Didelot wrote:
> VLAN aware Marvell chips can program 802.1Q VLAN membership as well as
> 802.1s per VLAN Spanning Tree state using the same 3 VTU Data registers.
> 
> Some chips such as 88E6185 use different Data registers offsets for
> ports state and membership, and program them in a single operation.
> 
> Other chips such as 88E6352 use the same register layout but program
> them in distinct operations (an indirect table is used for 802.1s.)
> 
> Newer chips such as 88E6390 use the same offsets for both state and
> membership in distinct operations, thus require multiple data accesses.
> 
> To correctly abstract this, split the "data" structure member of
> mv88e6xxx_vtu_entry in two "state" and "member" members, before adding
> VTU support for newer chips.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
