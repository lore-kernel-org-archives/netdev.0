From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 09/18] net: dsa: mv88e6xxx: move VTU Data
 accessors
Date: Thu, 27 Apr 2017 21:19:42 +0200
Message-ID: <20170427191942.GL17364@lunn.ch>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
 <20170426155336.5937-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43726 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937348AbdD0TTp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 15:19:45 -0400
Content-Disposition: inline
In-Reply-To: <20170426155336.5937-10-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 11:53:27AM -0400, Vivien Didelot wrote:
> The code to access the VTU Data registers currently only supports the
> 88E6185 family and alike: 2-bit membership adjacent to 2-bit port state.
> 
> Even though the 88E6352 family introduced an indirect table to program
> the VLAN Spanning Tree states, the usage of the VTU Data registers
> remains the same regardless the VTU or STU operation.
> 
> Now that the mv88e6xxx_vtu_entry structure contains both port membership
> and states data, factorize the code to access them in global1_vtu.c.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
