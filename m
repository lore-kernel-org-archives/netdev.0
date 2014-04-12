From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: sun4i-emac: add promiscuous support
Date: Sat, 12 Apr 2014 02:01:13 -0400 (EDT)
Message-ID: <20140412.020113.53160144126143189.davem@davemloft.net>
References: <1397209577-24443-1-git-send-email-marc.zyngier@arm.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=ISO-8859-1
Cc: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sr-ynQEQJNshbs@public.gmane.org,
 maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: marc.zyngier-5wv7dgnIgG8@public.gmane.org
Return-path: <linux-sunxi+bncBDCIDJ4RTAOBBK5NUONAKGQEPNBVIQI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1397209577-24443-1-git-send-email-marc.zyngier-5wv7dgnIgG8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>
Date: Fri, 11 Apr 2014 10:46:17 +0100

> The sun4i-emac driver is rather primitive, and doesn't support
> promiscuous mode. This makes usage such as bridging impossible,
> which is a shame on virtualization capable HW such as the
> Allwinner A20.
> 
> The fix is fairly simple: move the RX setup code to the ndo_set_rx_mode
> vector, and add the required HW configuration when IFF_PROMISC is passed
> by the core code.
> 
> This has been tested on a generic A20 box running a few virtual
> machines hanging off a bridge with the EMAC chip as the link to the
> outside world.
> 
> Cc: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
> Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> Signed-off-by: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>

Applied.
