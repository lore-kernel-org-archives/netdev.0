From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 2/3] [POWERPC] fsl_soc: add support for gianfar for
	fixed-link property
Date: Mon, 26 Nov 2007 16:04:08 +0100
Message-ID: <1196089448.12625.62.camel@gentoo-jocke.transmode.se>
References: <20071126142906.19642.45540.stgit@localhost.localdomain>
	<20071126142915.19642.5842.stgit@localhost.localdomain>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071126142915.19642.5842.stgit@localhost.localdomain>
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

On Mon, 2007-11-26 at 17:29 +0300, Vitaly Bordug wrote:
> fixed-link says: register new "Fixed/emulated PHY", i.e. PHY that
> not connected to the real MDIO bus.
> 
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> 
> ---
> 
>  Documentation/powerpc/booting-without-of.txt |    3 +
>  arch/powerpc/sysdev/fsl_soc.c                |   56 ++++++++++++++++++--------
>  2 files changed, 42 insertions(+), 17 deletions(-)
> 
> 
> diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
> index e9a3cb1..cf25070 100644
> --- a/Documentation/powerpc/booting-without-of.txt
> +++ b/Documentation/powerpc/booting-without-of.txt
> @@ -1254,6 +1254,9 @@ platforms are moved over to use the flattened-device-tree model.
>        services interrupts for this device.
>      - phy-handle : The phandle for the PHY connected to this ethernet
>        controller.
> +    - fixed-link : <a b c> where a is emulated phy id - choose any,
> +      but unique to the all specified fixed-links, b is duplex - 0 half,
> +      1 full, c is link speed - d#10/d#100/d#1000.

Good work!
May I suggest adding a "d" to <a b c> where d is flow control - 0 no, 1 yes

flow control or not just popped up here today so I got a use for it.

 Jocke 
