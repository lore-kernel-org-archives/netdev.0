From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] powerpc/83xx: gianfar_ptp: select 1588 clock source
 through dts file
Date: Mon, 30 Sep 2013 14:50:56 -0400 (EDT)
Message-ID: <20130930.145056.669909746688674911.davem@davemloft.net>
References: <1380093863-5388-1-git-send-email-aida.mynzhasova@skitlab.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380093863-5388-1-git-send-email-aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
Date: Wed, 25 Sep 2013 11:24:23 +0400

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

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
