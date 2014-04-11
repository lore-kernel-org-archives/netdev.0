From: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>
Subject: Re: [PATCH] net: sun4i-emac: add promiscuous support
Date: Fri, 11 Apr 2014 11:55:50 +0200
Message-ID: <5347BC26.4070907@denx.de>
References: <1397209577-24443-1-git-send-email-marc.zyngier@arm.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Marc Zyngier <marc.zyngier-5wv7dgnIgG8@public.gmane.org>, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-sunxi+bncBCXMVYMKQEGRBC7YT2NAKGQEWLUECEY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1397209577-24443-1-git-send-email-marc.zyngier-5wv7dgnIgG8@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 11.04.2014 11:46, Marc Zyngier wrote:
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

Looks good, so:

Acked-by: Stefan Roese <sr-ynQEQJNshbs@public.gmane.org>

Thanks,
Stefan
