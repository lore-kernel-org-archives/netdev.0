From: Rob Herring <robherring2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Mon, 27 Jan 2014 09:56:12 -0600
Message-ID: <CAL_JsqLi0QKeeUkGMKmYZ1ki02mzk=L1gDxTJyXFGiOe_aHiVw@mail.gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-1-git-send-email-alchark@gmail.com>
	<1390823503-24087-4-git-send-email-alchark@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Tony Prisk <linux-ci5G2KO2hbZ+pU9mqzGVBQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1390823503-24087-4-git-send-email-alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 27, 2014 at 5:51 AM, Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This should make the driver usable with VIA/WonderMedia ARM-based
> Systems-on-Chip integrated Rhine III adapters. Note that these
> are always in MMIO mode, and don't have any known EEPROM.
>
> Signed-off-by: Alexey Charkov <alchark-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Roger Luethi <rl-7uj+XXdSDtwfv37vnLkPlQ@public.gmane.org>
> ---
>  .../devicetree/bindings/net/via-rhine.txt          |  18 ++
>  drivers/net/ethernet/via/Kconfig                   |   2 +-
>  drivers/net/ethernet/via/via-rhine.c               | 293 +++++++++++++--------
>  3 files changed, 200 insertions(+), 113 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/via-rhine.txt
>
> diff --git a/Documentation/devicetree/bindings/net/via-rhine.txt b/Documentation/devicetree/bindings/net/via-rhine.txt
> new file mode 100644
> index 0000000..684dd3a
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/via-rhine.txt
> @@ -0,0 +1,18 @@
> +* VIA Rhine 10/100 Network Controller
> +
> +Required properties:
> +- compatible : Should be "via,rhine"

This should be more specific rather than...

> +- reg : Address and length of the io space
> +- interrupts : Should contain the controller interrupt line
> +- rhine,revision : Rhine core revision, used to inform the
> +       driver of quirks and capabilities to expect from
> +       the device. Mimics the respective PCI attribute.

having this property. The OF match table can then have the quirks set
based on compatible strings.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
