From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH 1/2] ibm_newemac: Add Support for MAL Interrupt Coalescing
Date: Tue, 22 Sep 2009 11:09:51 +1000
Message-ID: <1253581792.7103.195.camel@pasglop>
References: <1253573245-1867-1-git-send-email-phazarika@amcc.com>
	<1253576514.7103.165.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D606FFE802@SDCEXCHANGE01.ad.amcc.com>
	<1253578361.7103.180.camel@pasglop>
	<49c0ff980909211728s2d39e356p6900d047c6918826@mail.gmail.com>
	<1253579943.7103.194.camel@pasglop>
	<0CA0A16855646F4FA96D25A158E299D606FFE81A@SDCEXCHANGE01.ad.amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Victor Gallardo <vgallardo@amcc.com>, Feng Kan <fkan@amcc.com>,
	netdev@vger.kernel.org, lada.podivin@gmail.com,
	Loc Ho <lho@amcc.com>, linuxppc-dev@lists.ozlabs.org,
	bhutchings@solarflare.com, prodyut hazarika <prodyuth@gmail.com>,
	davem@davemloft.net
To: Prodyut Hazarika <phazarika@amcc.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <0CA0A16855646F4FA96D25A158E299D606FFE81A@SDCEXCHANGE01.ad.amcc.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-09-21 at 17:53 -0700, Prodyut Hazarika wrote:
> 
> In the newer revs of 460EX/GT and 405EX, we have Interrupt coalescing
> both on Tx and Rx per channel (physical not virtual), which can be
> enabled/disabled per channel via UIC. The Tx/Rx Coalesce mappings are
> defined in the dts file. But in the older revs, there is only a global
> EOP_Int_Enable in the MAL configuration register. There can be a
> possible way even for older SoCs if we use the MAL descriptor I bit
> and
> not the global EOP_Int_Enable. But to turn on/off the channel, we will
> have to go and set/clear the I bit in whole of MAL descriptor ring for
> that channel. That might be really inefficient.
> 
> What would you suggest?

I wouldn't bother with the old SoCs, we should keep the current
workaround we have today for them. For the new ones, I'll have a look
and see how we can get the driver upgraded to avoid the workaround.

Don't bother with this for now. I'll dig at some stage.

Cheers,
Ben.
