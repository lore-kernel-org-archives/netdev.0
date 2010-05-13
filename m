From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] drivers/net: Remove unnecessary returns from
 void function()s
Date: Thu, 13 May 2010 09:58:06 -0700
Message-ID: <1273769886.21514.72.camel@Joe-Laptop.home>
References: <1273606224.20514.295.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2227 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756028Ab0EMQ6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 12:58:08 -0400
Received: from [192.168.1.151] (new-host-5.home [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id 38C0124368
	for <netdev@vger.kernel.org>; Thu, 13 May 2010 09:57:33 -0700 (PDT)
In-Reply-To: <1273606224.20514.295.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-11 at 12:30 -0700, Joe Perches wrote:
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
> index 2aa3367..02497bc 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -368,15 +368,12 @@ void bond_unregister_ipv6_notifier(void);
>  #else
>  static inline void bond_send_unsolicited_na(struct bonding *bond)
>  {
> -	return;
>  }
>  static inline void bond_register_ipv6_notifier(void)
>  {
> -	return;
>  }
>  static inline void bond_unregister_ipv6_notifier(void)
>  {
> -	return;
>  }
>  #endif

fyi: Patrick McHardy prefers null statement void functions to
keep the return.

There are some more removals of return like this in the patch.
If a new patch should be generated, do tell.

