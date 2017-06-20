From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/4] net-next: stmmac: dwmac-sun8i: add
 support for V3s
Date: Tue, 20 Jun 2017 13:23:23 -0400 (EDT)
Message-ID: <20170620.132323.46663908524667004.davem@davemloft.net>
References: <20170617140737.41951-1-icenowy@aosc.io>
Reply-To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: icenowy-h8G6r0blFSE@public.gmane.org
Return-path: <linux-sunxi+bncBCFPF2XH6UDBBDVUUXFAKGQE3TES7AI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170617140737.41951-1-icenowy-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Date: Sat, 17 Jun 2017 22:07:33 +0800

> Allwinner V3s features an EMAC like the on in H3, but without external MII
> interfaces, so being not able really to use RMII/RGMII.
> 
> And it has a different default value of syscon (0x38000 instead of 0x58000
> on H3), which shows a problem that the EMAC clock freq should be 24MHz.
> (Both H3 and V3s SoCs doesn't have extra xtal input for EPHY, and the
> main xtal is 24MHz. The default value of H3 is set to 24MHz, but the V3s
> default value is set to 25MHz).
> 
> First two patches are device tree binding patches, the third forces
> the frequency to 24MHz and the fourth really add the V3s support.

Series applied to net-next, thanks!
