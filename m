From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 01/12] net: dsa: mv88e6xxx: remove basic
 function flags
Date: Mon, 18 Jul 2016 21:25:32 +0200
Message-ID: <20160718192532.GH31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44928 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbcGRTZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:25:34 -0400
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 02:46:17PM -0400, Vivien Didelot wrote:
> All 88E6xxx Marvell switches (even the old not supported yet 88E6060)
> have at least an ATU, per-port STP states and VLAN map, to run basic
> switch functions such as Spanning Tree and port based VLANs.
> 
> Get rid of the related MV88E6XXX_FLAG_{ATU,PORTSTATE,VLANTABLE} flags,
> as they are defaults to every chip.
> 
> This enables STP on 6185 and removes many inconsistencies on others.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
