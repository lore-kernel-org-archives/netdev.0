From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v4] vxlan: Allow setting destination to unicast
 address.
Date: Thu, 18 Apr 2013 15:53:06 -0700
Message-ID: <20130418155306.73a9b0fc@nehalam.linuxnetplumber.net>
References: <874nf6r5uc.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Stevens <dlstevens@us.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f65.google.com ([209.85.210.65]:34522 "EHLO
	mail-da0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753871Ab3DRXLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 19:11:14 -0400
Received: by mail-da0-f65.google.com with SMTP id r6so386745dad.0
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 16:11:13 -0700 (PDT)
In-Reply-To: <874nf6r5uc.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Apr 2013 21:57:15 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 40167af..7064f27 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -293,7 +293,7 @@ enum macvlan_mode {
>  enum {
>  	IFLA_VXLAN_UNSPEC,
>  	IFLA_VXLAN_ID,
> -	IFLA_VXLAN_GROUP,
> +	IFLA_VXLAN_REMOTE,
>  	IFLA_VXLAN_LINK,
>  	IFLA_VXLAN_LOCAL,
>  	IFLA_VXLAN_TTL,

This doesn't match header in kernel.
Don't worry, I won't merge the 3.10 (current net-next) stuff until
after 3.10 merge window, and first step is to update headers.
