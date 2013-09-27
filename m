From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v3] powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file
Date: Fri, 27 Sep 2013 10:28:01 -0500
Message-ID: <21CA07A6-8B3D-49E9-8D9A-F63607FAC8EF@kernel.crashing.org>
References: <1380289227-12029-1-git-send-email-aida.mynzhasova@skitlab.ru>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380289227-12029-1-git-send-email-aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Sep 27, 2013, at 8:40 AM, Aida Mynzhasova wrote:

> Currently IEEE 1588 timer reference clock source is determined through
> hard-coded value in gianfar_ptp driver. This patch allows to select ptp
> clock source by means of device tree file node.
> 
> For instance:
> 
> 	fsl,cksel = <0>;
> 
> for using external (TSEC_TMR_CLK input) high precision timer
> reference clock.
> 
> Other acceptable values:
> 
> 	<1> : eTSEC system clock
> 	<2> : eTSEC1 transmit clock
> 	<3> : RTC clock input
> 
> When this attribute isn't used, eTSEC system clock will serve as
> IEEE 1588 timer reference clock.
> 
> Signed-off-by: Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
> ---
> Documentation/devicetree/bindings/net/fsl-tsec-phy.txt | 18 +++++++++++++++++-
> drivers/net/ethernet/freescale/gianfar_ptp.c           |  4 +++-
> 2 files changed, 20 insertions(+), 2 deletions(-)

Acked-by: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>

- k--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
