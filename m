From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Sat, 12 Apr 2008 05:12:13 -0400
Message-ID: <48007CED.5030601@garzik.org>
References: <m3prtzsszg.fsf@maximus.localdomain> <m3tzj92xq6.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41668 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757432AbYDLJMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:12:16 -0400
In-Reply-To: <m3tzj92xq6.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> New synchronous PPP implementation for generic HDLC.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> 
>  drivers/net/wan/Makefile   |    2 +-
>  drivers/net/wan/hdlc_ppp.c |  649 ++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 602 insertions(+), 49 deletions(-)
> 
> diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
> index d61fef3..3081683 100644
> --- a/drivers/net/wan/Makefile
> +++ b/drivers/net/wan/Makefile
> @@ -14,7 +14,7 @@ obj-$(CONFIG_HDLC_RAW)		+= hdlc_raw.o
>  obj-$(CONFIG_HDLC_RAW_ETH)	+= hdlc_raw_eth.o
>  obj-$(CONFIG_HDLC_CISCO)	+= hdlc_cisco.o
>  obj-$(CONFIG_HDLC_FR)		+= hdlc_fr.o
> -obj-$(CONFIG_HDLC_PPP)		+= hdlc_ppp.o	syncppp.o
> +obj-$(CONFIG_HDLC_PPP)		+= hdlc_ppp.o
>  obj-$(CONFIG_HDLC_X25)		+= hdlc_x25.o

applied


