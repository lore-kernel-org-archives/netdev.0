From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH NEXT V2] rtlwifi: Fix endian error in extracting packet
 type
Date: Thu, 31 Oct 2013 19:04:01 -0700
Message-ID: <1383271441.2769.18.camel@joe-AO722>
References: <1383266638-4813-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1383267769.1583.8.camel@bwh-desktop.uk.level5networks.com>
	 <1383270515.2769.15.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org,
	Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0237.hostedemail.com ([216.40.44.237]:34395 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755612Ab3KACEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 22:04:05 -0400
In-Reply-To: <1383270515.2769.15.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-31 at 18:48 -0700, Joe Perches wrote:
> Or maybe something like this?
[]
> diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
[]
> +		src = be16_to_cpu(udp->source) >> 8;
> +		dst = be16_to_cpu(udp->dest) >> 8;

Of course this doesn't need the >> 8;
