From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: x_tables: replace IPv4 dscp match by address
	family independent version
Date: Sun, 24 Sep 2006 21:02:38 +0100
Message-ID: <1159128158.24527.948.camel@pmac.infradead.org>
References: <200609240002.k8O02wT5010490@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:12764 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751212AbWIXUCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 16:02:52 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200609240002.k8O02wT5010490@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-24 at 00:02 +0000, Linux Kernel Mailing List wrote:
> --- a/include/linux/netfilter_ipv4/ipt_dscp.h
> +++ b/include/linux/netfilter_ipv4/ipt_dscp.h
> @@ -10,14 +10,12 @@
>  #ifndef _IPT_DSCP_H
>  #define _IPT_DSCP_H
>  
> -#define IPT_DSCP_MASK  0xfc    /* 11111100 */
> -#define IPT_DSCP_SHIFT 2
> -#define IPT_DSCP_MAX   0x3f    /* 00111111 */
> +#include <linux/netfilter/xt_dscp.h> 

This causes the following error in 'make headers_check':

linux/netfilter_ipv4/ipt_DSCP.h requires linux/netfilter/xt_DSCP.h,
which does not exist in exported headers
make[4]: *** [ipt_DSCP.h] Error 1

Please remember to run 'make headers_check' before submitting patches.

-- 
dwmw2

