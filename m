From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] dt-bindings: net: dsa: add Mediatek MT7530
 binding
Date: Mon, 13 Mar 2017 09:47:23 -0700
Message-ID: <928d1178-e04a-3e78-4a7a-36127321a949@gmail.com>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-2-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
 vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1489421488-300-2-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 09:11 AM, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
> From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> 
> Add device-tree binding for Mediatek MT7530 switch.
> 
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> ---
>  .../devicetree/bindings/net/dsa/mt7530.txt         | 94 ++++++++++++++++++++++
>  1 file changed, 94 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/mt7530.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/mt7530.txt b/Documentation/devicetree/bindings/net/dsa/mt7530.txt
> new file mode 100644
> index 0000000..0e50dbf
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/mt7530.txt
> @@ -0,0 +1,94 @@
> +Mediatek MT7530 Ethernet switch
> +================================
> +
> +Required properties:
> +
> +- compatible: Must be compatible = "mediatek,mt7530";
> +- #address-cells: Must be 1
> +- #size-cells: Must be 0
> +- mediatek,ethsys: Phandle to the syscon node that handles the reset.
> +- mediatek,ethernet: Phandle to the syscon node that Mediatek ethernet driver
> +	provides that handles the TRGMII setup used by the switch.
> +	See
> +	Documentation/devicetree/bindings/net/mediatek-net.txt for the detailed
> +	setup on mediatek ethernet.

This seems redundant with the CPU port's ethernet phandle here.
-- 
Florian
