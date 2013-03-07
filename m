From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool get/set
 phy setting
Date: Thu, 7 Mar 2013 22:43:12 +0530
Message-ID: <5138CAA8.1060106@ti.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
 <1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
 <8762135on4.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <8762135on4.fsf-D6SC8u56vOOJDPpyT6T3/w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 3/7/2013 6:54 PM, Peter Korsgaard wrote:
>>>>>> "M" == Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> writes:
>   M> This patch implements get/set of the phy settings via ethtool apis
>   M> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>   M> ---
>   M>  Documentation/devicetree/bindings/net/cpsw.txt |    3 +++
>   M>  drivers/net/ethernet/ti/cpsw.c                 |   32 ++++++++++++++++++++++++
>   M>  include/linux/platform_data/cpsw.h             |    1 +
>   M>  3 files changed, 36 insertions(+)
>
>   M> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>   M> index ecfdf75..8d61300 100644
>   M> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>   M> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>   M> @@ -20,6 +20,7 @@ Required properties:
>   M>  - cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
>   M>  - phy_id		: Specifies slave phy id
>   M>  - mac-address		: Specifies slave MAC address
>   M> +- ethtool-active-slave	: Specifies the slave to use for ethtool command
>
> That again sounds like something Linux specific rather than a hardware
> property.
>
> It would be good if all these special things (dual emac mode, vlan
> handling, switching) could be handled using the existing kernel
> (bridging/vlan) infrastructure, and the driver always just exposing 2
> network interfaces instead of these configuration properties.
>
Switch and Dual Emac modes of operation of CPSW are two different 
features of the
hardware and packet routing between the slaves in the hardware are 
different in
both the modes.

If by default it is brought up as Dual EMAC then hardware switching is 
blocked and
use-cases like IP phone etc cannot be achieved.

Since CPSW as a hardware Switch, it cannot not be handled in existing kernel
feature.

Regards
Mugunthan V N
