From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h>
 defines
Date: Wed, 25 Apr 2012 20:38:31 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD36CAE@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335367808-4254-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>
To: Linus Walleij <linus.walleij@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe001.messaging.microsoft.com ([213.199.154.139]:11699
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758882Ab2DYUik convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:38:40 -0400
In-Reply-To: <1335367808-4254-1-git-send-email-linus.walleij@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Linus Walleij [mailto:linus.walleij@linaro.org]
> Sent: Wednesday, April 25, 2012 11:30 AM
> To: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Greg Kroah-Hartman;
> David S. Miller; Felipe Balbi
> Cc: Jussi Kivilinna; Haiyang Zhang; Wei Yongjun; Ben Hutchings; Linus
> Walleij
> Subject: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h>
> defines
> 
> As a first step to consolidate the RNDIS implementations, break out
> a common file with all the #defines and move it to <linux/rndis.h>.
> The compilation screams about double-defines all over the place
> (as could be expected, this is why we're consolidating) but it
> compiles cleanly still.
> 
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
>  drivers/net/hyperv/hyperv_net.h   |  290 +-----------------
>  drivers/net/wireless/rndis_wlan.c |   49 ---
>  drivers/usb/gadget/ndis.h         |  164 ----------
>  drivers/usb/gadget/rndis.h        |   48 +---
>  include/linux/rndis.h             |  615
> +++++++++++++++++++++++++++++++++++++
>  include/linux/usb/rndis_host.h    |   66 +----
>  6 files changed, 619 insertions(+), 613 deletions(-)
>  create mode 100644 include/linux/rndis.h
> 

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
