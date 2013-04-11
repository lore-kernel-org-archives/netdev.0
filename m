From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] vxlan: Allow setting destination to unicast
 address.
Date: Thu, 11 Apr 2013 08:24:38 -0700
Message-ID: <20130411082438.7fe3421b@nehalam.linuxnetplumber.net>
References: <87li8pmkvh.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:36732 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936173Ab3DKPZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 11:25:00 -0400
Received: by mail-pb0-f47.google.com with SMTP id rq13so914584pbb.20
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 08:25:00 -0700 (PDT)
In-Reply-To: <87li8pmkvh.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Apr 2013 19:17:54 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 40167af..0bf03dc 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -296,6 +296,7 @@ enum {
>  	IFLA_VXLAN_GROUP,
>  	IFLA_VXLAN_LINK,
>  	IFLA_VXLAN_LOCAL,
> +	IFLA_VXLAN_REMOTE,
>  	IFLA_VXLAN_TTL,
>  	IFLA_VXLAN_TOS,

You can't insert another value into the middle of an enum list.
It changes the kernel-userspace ABI values.
