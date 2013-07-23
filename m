From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 1/2] realtek: convert to per-chip mask
Date: Tue, 23 Jul 2013 22:24:37 +0200
Message-ID: <20130723202437.GC31567@electric-eye.fr.zoreil.com>
References: <3162188.mmLmSZRt9A@al>
 <1602191.cqZWCGFrek@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51232 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932470Ab3GWUYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 16:24:44 -0400
Content-Disposition: inline
In-Reply-To: <1602191.cqZWCGFrek@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> diff --git a/realtek.c b/realtek.c
> index c3d7ae5..5a1fba7 100644
> --- a/realtek.c
> +++ b/realtek.c
[...]
> @@ -35,36 +32,62 @@ enum chip_type {
>  	RTL8100E2,
>  };
>  
> -enum {
> -	chip_type_mask = HW_REVID(1, 1, 1, 1, 1, 1, 1, 1)
> +static const char * const chip_names[] = {
> +	[RTL8139] = "RTL-8139",
> +	[RTL8139_K] = "RTL-8139-K",
> +	[RTL8139A] = "RTL-8139A",
> +	[RTL8139A_G] = "RTL-8139A-G",
> +	[RTL8139B] = "RTL-8139B",
> +	[RTL8130] = "RTL-8130",
> +	[RTL8139C] = "RTL-8139C",
> +	[RTL8100] = "RTL-8100",
> +	[RTL8100B_8139D] = "RTL-8100B/8139D",
> +	[RTL8139C] = "RTL-8139C+",
> +	[RTL8101] = "RTL-8101",
> +
> +	/* chips not handled by 8139too/8139cp module */
> +	[RTL8169] = "RTL-8169",
> +	[RTL8169S] = "RTL-8169S",
> +	[RTL8110S] = "RTL-8110S",
> +	[RTL8169_8110SB] = "RTL-8169/8110SB",
> +	[RTL8169_8110SCd] = "RTL-8169/8110SCd",
> +	[RTL8169_8110SCe] = "RTL-8169/8110SCe",
> +	[RTL8168_8111Bb] = "RTL-8168/8111Bb",
> +	[RTL8168_8111Bef] = "RTL-8168/8111Bef",
> +	[RTL8101Ebc] = "RTL-8101Ebc",
> +	[RTL8100E1] = "RTL-8100E(1)",
> +	[RTL8100E2] = "RTL-8100E(2)",

Tab after equal may be.

The "RTL-" prefix string could be shared.

-- 
Ueimor
