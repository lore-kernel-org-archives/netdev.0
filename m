From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH rfc 1/5] r8169: style cleanups.
Date: Wed, 27 Apr 2011 13:59:34 -0700
Message-ID: <1303937974.24299.92.camel@Joe-Laptop>
References: <20110427203654.GD19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1055 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751227Ab1D0U7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 16:59:35 -0400
In-Reply-To: <20110427203654.GD19708@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-27 at 22:36 +0200, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
[]
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
[]
> @@ -3134,8 +3128,8 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
[]
> -	if (tp->mac_version == RTL_GIGA_MAC_VER_32 ||
> -	    tp->mac_version == RTL_GIGA_MAC_VER_33)
> +	if ((tp->mac_version == RTL_GIGA_MAC_VER_32) ||
> +	    (tp->mac_version == RTL_GIGA_MAC_VER_33))

Shrug.  I don't think this is better.


