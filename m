From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/4] net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY
 addr >= num_of_ports
Date: Mon, 19 Dec 2016 15:56:06 +0100
Message-ID: <20161219145606.GD10048@lunn.ch>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-3-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Romain Perier <romain.perier@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20161219141610.30934-3-romain.perier@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 03:16:07PM +0100, Romain Perier wrote:
> Some Marvell ethernet switches have internal ethernet transceivers with
> hardcoded phy addresses. These addresses can be grearer than the number
> of ports or its value might be different than the associated port number.
> This is for example the case for MV88E6341 that has 6 ports and internal
> Port 1 to Port4 PHYs mapped at SMI addresses from 0x11 to 0x14.
> 
> This commits fixes the issue by removing the condition in MDIO callbacks.
> 
> Signed-off-by: Romain Perier <romain.perier@free-electrons.com>

So it is not quite compatible with the 6352. Thanks Marvell :-(

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
