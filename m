From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 3/3] driver: net: ethernet: cpsw: dual emac interface
 implementation
Date: Mon, 18 Feb 2013 20:40:48 +0530
Message-ID: <51224478.7050304@ti.com>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
 <1360612340-9266-4-git-send-email-mugunthanvnm@ti.com>
 <87mwv1kaln.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <87mwv1kaln.fsf-D6SC8u56vOOJDPpyT6T3/w@public.gmane.org>
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

On 2/18/2013 7:06 PM, Peter Korsgaard wrote:
>>>>>> "M" == Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> writes:
>   M> The CPSW switch can act as Dual EMAC by segregating the switch ports
>   M> using VLAN and port VLAN as per the TRM description in
>   M> 14.3.2.10.2 Dual Mac Mode
>
>   M> Following CPSW components will be common for both the interfaces.
>   M> * Interrupt source is common for both eth interfaces
>   M> * Interrupt pacing is common for both interfaces
>   M> * Hardware statistics is common for all the ports
>   M> * CPDMA is common for both eth interface
>   M> * CPTS is common for both the interface and it should not be enabled on
>   M>   both the interface as timestamping information doesn't contain port
>   M>   information.
>
>   M> Constrains
>   M> * Reserved VID of One port should not be used in other interface which will
>   M>   enable switching functionality
>   M> * Same VID must not be used in both the interface which will enable switching
>   M>   functionality
>
>   M> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
>   M> ---
>   M>  Documentation/devicetree/bindings/net/cpsw.txt |    2 +
>   M>  drivers/net/ethernet/ti/cpsw.c                 |  335 ++++++++++++++++++++----
>   M>  include/linux/platform_data/cpsw.h             |    3 +
>   M>  3 files changed, 288 insertions(+), 52 deletions(-)
>
>   M> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>   M> index 6ddd028..ecfdf75 100644
>   M> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>   M> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>   M> @@ -24,6 +24,8 @@ Required properties:
>   M>  Optional properties:
>   M>  - ti,hwmods		: Must be "cpgmac0"
>   M>  - no_bd_ram		: Must be 0 or 1
>   M> +- dual_emac		: Specifies Switch to act as Dual EMAC
>   M> +- dual_emac_res_vlan	: Specifies VID to be used to segregate the ports
>
> You forgot to CC devicetree-discuss. Properties normally use dashes (-)
> instead of underscores (_). These properties are more about
> configuration and not hardware.
>
> It is not clear to me from the description that dual_emac is a boolean
> (0/1). Shouldn't dual_emacs_res_vlan be a property of the slave?
>
> It would also be good to update the example below with this.
Since the series is already applied in net-next tree, i will submit a 
patch with incorporating
the above comments. Will add devicetree-discuss in my future patches.

Regards
Mugunthan V N
