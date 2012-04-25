From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH 00/14 v2] usb/net: rndis: first step toward consolidation
Date: Wed, 25 Apr 2012 20:36:47 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC0DD36C9E@TK5EX14MBXC221.redmond.corp.microsoft.com>
References: <1335367783-4184-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	KY Srinivasan <kys@microsoft.com>
To: Linus Walleij <linus.walleij@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:59838
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758878Ab2DYUhQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 16:37:16 -0400
In-Reply-To: <1335367783-4184-1-git-send-email-linus.walleij@linaro.org>
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
> Subject: [PATCH 00/14 v2] usb/net: rndis: first step toward consolidation
> 
> A second spin of the RNDIS unification patches.
> Jussi Kivilinna pointed out an error where I was joining
> "media" and "physical media" in patch 9, this was all wrong
> so now I've fixed it up.
> 
> Please test!
> 
> If this thing works I guess it should propagate through
> dmillers tree eventually.
> 
> Linus Walleij (14):
>   usb/net: rndis: inline the cpu_to_le32() macro
>   usb/net: rndis: break out <linux/rndis.h> defines
>   usb/net: rndis: remove duplicate definitions
>   usb/net: rndis: remove ambigous status codes
>   usb/net: rndis: eliminate first set of duplicate OIDs
>   usb/net: rndis: merge duplicate 802_* OIDs
>   usb/net: rndis: delete surplus defines
>   usb/net: rndis: group all status codes together
>   usb/net: rndis: merge media type definitions
>   usb/net: rndis: delete duplicate packet types
>   usb/net: rndis: move and namespace PnP defines
>   usb/net: rndis: merge command codes
>   usb/net: rndis: fixup a few name prefixes
>   usb/net: rndis: move bus message definition
> 
>  drivers/net/hyperv/hyperv_net.h   |  290 +---------------------------
>  drivers/net/hyperv/rndis_filter.c |   46 +++---
>  drivers/net/usb/rndis_host.c      |   52 +++---
>  drivers/net/wireless/rndis_wlan.c |  295 ++++++++++++----------------
>  drivers/usb/gadget/f_rndis.c      |    6 +-
>  drivers/usb/gadget/ndis.h         |  164 ----------------
>  drivers/usb/gadget/rndis.c        |  271 +++++++++++++-------------
>  drivers/usb/gadget/rndis.h        |   48 +-----
>  include/linux/rndis.h             |  390
> +++++++++++++++++++++++++++++++++++++
>  include/linux/usb/rndis_host.h    |   66 +------
>  10 files changed, 706 insertions(+), 922 deletions(-)
>  create mode 100644 include/linux/rndis.h
> 
> --
> 1.7.7.6
> 

I tested Hyper-V netvsc driver, it works fine with the patches.

Thanks,
- Haiyang
