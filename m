From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth.c, make PHY device optional.
Date: Wed, 04 Jul 2007 18:44:39 +0200
Message-ID: <1183567479.20673.225.camel@gentoo-jocke.transmode.se>
References: <989B956029373F45A0B8AF0297081890D839B4@zch01exm26.fsl.freescale.net>
	<B27F0350-E5ED-48BF-9605-1E6BE29B9E36@kernel.crashing.org>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <B27F0350-E5ED-48BF-9605-1E6BE29B9E36@kernel.crashing.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-04 at 15:32 +0200, Segher Boessenkool wrote:
> > How about separate autoneg to a property "dumb-phy", which  
> > indicates the
> > PHY/switch doesn't provide MII register interface.
> 
> Something like that I suppose.  But don't call it "dumb phy",
> nor "fake phy", nor anything similar -- there simply is _no_
> phy.  If the Linux code wants to pretend there is one, that's
> one thing, but there is no need to do any of this trickery in
> the device tree.
> 
> > Therefore, it should
> > use the fixed speed and duplex from device node rather than registers.
> 
> Yes.

Not sure I follow, something like this?
  initial-phy-capacity = <speed duplex>
  no-mdio-interface

autoneg does not fit in there.

Jocke
