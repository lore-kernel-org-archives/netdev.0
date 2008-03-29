From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/2] ibm_newemac: PowerPC 440GX EMAC PHY clock workaround
Date: Sat, 29 Mar 2008 14:28:16 +1100
Message-ID: <1206761296.10388.85.camel@pasglop>
References: <20080327144044.GA8831@ru.mvista.com> <47EDA6F1.9080206@garzik.org>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <47EDA6F1.9080206@garzik.org>
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


On Fri, 2008-03-28 at 22:18 -0400, Jeff Garzik wrote:
> Valentine Barshak wrote:
> > The PowerPC 440GX Taishan board fails to reset EMAC3 (reset timeout error)
> > if there's no link. Because of that it fails to find PHY chip. The older ibm_emac
> > driver had a workaround for that: the EMAC_CLK_INTERNAL/EMAC_CLK_EXTERNAL macros,
> > which toggle the Ethernet Clock Select bit in the SDR0_MFR register. This patch
> > does the same for "ibm,emac-440gx" compatible chips. The workaround forces
> > clock on -all- EMACs, so we select clock under global emac_phy_map_lock.
> > 
> > Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> > ---
> >  drivers/net/ibm_newemac/core.c |   16 +++++++++++++++-
> >  drivers/net/ibm_newemac/core.h |    8 ++++++--
> >  2 files changed, 21 insertions(+), 3 deletions(-)
> 
> is this for 2.6.25-rc?

Nah, too late imho.

Ben.
