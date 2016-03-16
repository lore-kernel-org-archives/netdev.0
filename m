From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 2/9] net: arc_emac: add phy reset is optional for
 device tree
Date: Wed, 16 Mar 2016 16:57:42 +0300
Message-ID: <56E96656.5000101@cogentembedded.com>
References: <1457942520-12859-1-git-send-email-wxt@rock-chips.com>
 <1457942520-12859-3-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	leozwang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457942520-12859-3-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/14/2016 11:01 AM, Caesar Wang wrote:

> This patch adds the following property for arc_emac.
>
> 1) phy-reset-gpios:
> The phy-reset-gpio is an optional property for arc emac device tree boot.
> Change the binding document to match the driver code.
>
> 2) phy-reset-duration:
> Different boards may require different phy reset duration. Add property
> phy-reset-duration for device tree probe, so that the boards that need
> a longer reset duration can specify it in their device tree.
>
> Anyway, we can add the above property for arc emac.
>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>

   Could you have a look at drivers/net/ethernet/cadence/macb/? It seems to be 
the only driver which places the PHY's "reset-gpios" prop correctly, into the 
PHY subnode? I'm currently working on adding support of this prop into phylib...

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
