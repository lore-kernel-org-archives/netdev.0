From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: make unsolicited report intervals
 configurable for mld
Date: Tue, 13 Aug 2013 15:52:50 -0700 (PDT)
Message-ID: <20130813.155250.2046252303059223531.davem@davemloft.net>
References: <20130812112817.GC23241@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	william.manley@youview.com, bcrl@kvack.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45116 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3HMWwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:52:51 -0400
In-Reply-To: <20130812112817.GC23241@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 12 Aug 2013 13:28:17 +0200

> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 4bda4cf..315f133 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -147,6 +147,8 @@ enum {
>  	DEVCONF_MAX_DESYNC_FACTOR,
>  	DEVCONF_MAX_ADDRESSES,
>  	DEVCONF_FORCE_MLD_VERSION,
> +	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
> +	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
>  	DEVCONF_ACCEPT_RA_DEFRTR,
>  	DEVCONF_ACCEPT_RA_PINFO,
>  	DEVCONF_ACCEPT_RA_RTR_PREF,

Since these these values are in an UAPI header, and thus exported to userspace,
you can't add new enumeration values in the middle.  Otherwise you'll change
the existing enumerations, which could break userspace.

You'll have to add these new values to the end.
