From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ieee802154: removed unwanted header files
Date: Tue, 08 Jul 2014 20:56:05 -0700 (PDT)
Message-ID: <20140708.205605.1846044536261079477.davem@davemloft.net>
References: <1404877445-2757-1-git-send-email-varkab@cdac.in>
	<1404877445-2757-2-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.aring@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbaGID4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:56:07 -0400
In-Reply-To: <1404877445-2757-2-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkabhadram@gmail.com>
Date: Wed,  9 Jul 2014 09:14:04 +0530

> diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
> index 511ddee..d85caa2 100644
> --- a/net/ieee802154/6lowpan_iphc.c
> +++ b/net/ieee802154/6lowpan_iphc.c
> @@ -49,12 +49,8 @@
>   * SUCH DAMAGE.
>   */
>  
> -#include <linux/bitops.h>
> -#include <linux/if_arp.h>
>  #include <linux/module.h>
> -#include <linux/netdevice.h>
>  #include <net/6lowpan.h>
> -#include <net/ipv6.h>
>  #include <net/af_ieee802154.h>
>  

These changes are completely bogus.

Where are the definitions of the data types for "struct in6_addr" and
"struct ipv6hdr" coming from.

I'm not even going to look at these patches until you:

1) Properly audit the files.  Removing an include and typing "make"
   is not auditing the header file requriements.  Reading the code
   and looking at where declarations and definitions actually come
   from _is_.

2) Write a real commit message, this one is way too terse and tells me
   nothing.  Explain why each header file was removed, and what the
   justification is.
