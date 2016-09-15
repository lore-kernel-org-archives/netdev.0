From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH V2 1/3] Documentation: devicetree: add qca8k binding
Date: Thu, 15 Sep 2016 02:22:08 +0200
Message-ID: <20160915002208.GA29110@lunn.ch>
References: <1473849542-3298-1-git-send-email-john@phrozen.org>
 <1473849542-3298-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        qsdk-review-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1473849542-3298-2-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 12:39:00PM +0200, John Crispin wrote:
> Add device-tree binding for ar8xxx switch families.
> 
> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
> ---
> Changes in V2
> * fixup ecample to include phy nodes and corresponding phandles
> * add a note explaining why we need to phy nodes
> 
>  .../devicetree/bindings/net/dsa/qca8k.txt          |   88 ++++++++++++++++++++
>  1 file changed, 88 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dsa/qca8k.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/dsa/qca8k.txt b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
> new file mode 100644
> index 0000000..2c1582a
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
> @@ -0,0 +1,88 @@
> +* Qualcomm Atheros QCA8xxx switch family
> +
> +Required properties:
> +
> +- compatible: should be "qca,qca8337"
> +- #size-cells: must be 0
> +- #address-cells: must be 1
> +
> +Subnodes:
> +
> +The integrated switch subnode should be specified according to the binding
> +described in dsa/dsa.txt. As the QCA8K switches do not have a N:N mapping of
> +port and PHY id, each subnode describing a port needs to have a valid phandle
> +referencing the internal PHY connected to it.

Hi John

I've not looked at the driver yet, but you said yesterday the CPU port
has to be port 0. I think it would be good to document that here.

Otherwise, this is looking good.

	   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
