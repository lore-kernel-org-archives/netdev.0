From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 02/10] net: stmmac: Honor DT parameter to
 force DMA store and forward mode
Date: Sat, 7 Dec 2013 09:23:27 +0800
Message-ID: <CAGb2v67ZNtbQm+ZW5v_3wNbz1=oLhXks6gbTSjLYa=Nnoz8w-A@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-3-git-send-email-wens@csie.org> <20131206.162606.2277176361893801778.davem@davemloft.net>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"rob.herring" <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	"maxime.ripard" <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBI7RRGKQKGQECJJZEQA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20131206.162606.2277176361893801778.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Resending reply due to incorrect MIME type.

On Sat, Dec 7, 2013 at 5:26 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>
> From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> Date: Sat,  7 Dec 2013 01:29:35 +0800
>
> > @@ -47,6 +47,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
> >               plat->bus_id = 0;
> >
> >       of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr);
> > +     plat->force_sf_dma_mode = of_property_read_bool(np, "snps,force_sf_dma_mode");
>
> Will this do the right thing for when the property is not present?
> Right now the force_sf_dma_mode value is always false.

of_property_read_bool will return false when the property is not present.

> In fact won't it override the explicit settings done elsewhere in the
> driver?

Point taken. The current implementation will override settings passed from
platform data. ORing the two would be better.


Thanks
