From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ethtool: add get permanent address option (v2)
Date: Mon, 18 Oct 2010 13:16:11 -0700
Message-ID: <1287432971.2526.18.camel@Joe-Laptop>
References: <20101018114139.71073a40@nehalam>
	 <1287431541.2252.556.camel@achroite.uk.solarflarecom.com>
	 <20101018131104.02681d60@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3027 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933209Ab0JRUQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 16:16:12 -0400
In-Reply-To: <20101018131104.02681d60@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 13:11 -0700, Stephen Hemminger wrote:
> diff --git a/ethtool.c b/ethtool.c
[]
> @@ -750,7 +758,8 @@ static void parse_cmdline(int argc, char **argp)
>  			    (mode == MODE_SNTUPLE) ||
>  			    (mode == MODE_GNTUPLE) ||
>  			    (mode == MODE_PHYS_ID) ||
> -			    (mode == MODE_FLASHDEV)) {
> +			    (mode == MODE_FLASHDEV) |
> +			    (mode == MODE_PERMADDR)) {

One more vertical bar please.


