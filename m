From: Michal Suchanek <hramrach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/10] net: stmmac: Add sun7i GMAC glue layer
Date: Fri, 6 Dec 2013 21:52:06 +0100
Message-ID: <CAOMqctQLnky=K+uhJNVPTGq+MJVNFoG1OW5Zxo7P2MvrRf_Cug@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Return-path: <linux-sunxi+bncBCQMLUOX54MBBH7SRCKQKGQEQ6XXYTY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1386350983-13281-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 6 December 2013 18:29, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> wrote:
> Hi,
>
> This patch series adds Allwinner sun7i support to stmmac.
> The Allwinner sun7i SoC A20 integrates an early version of
> dwmac IP from Synopsys. On top of that is a hardware glue
> layer. This layer needs to be configured before the dwmac
> can be used.

...

> Comments?
>
> Thanks,
>
> wens
>
>
> Chen-Yu Tsai (10):
>   net: stmmac: Enable stmmac main clock when probing hardware
>   net: stmmac: Honor DT parameter to force DMA store and forward mode
>   net: stmmac: Use platform data tied with compatible strings
>   net: stmmac: sunxi platfrom extensions for GMAC in Allwinner A20 SoC's
>   ARM: dts: sun7i: Add GMAC controller node to sun7i DTSI
>   ARM: dts: sun7i: Add pin muxing options for the GMAC
>   ARM: dts: sun7i: cubietruck: Enable the GMAC
>   ARM: dts: sun7i: cubieboard2: Enable GMAC instead of EMAC
>   ARM: dts: sun7i: olinuxino-micro: Enable GMAC instead of EMAC
>   ARM: dts: sun7i: Add ethernet alias for GMAC

Tested-By: Michal Suchanek <hramrach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Works for me with RGMII and MII phy on top of 3.13rc3.

Thanks

Michal
