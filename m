From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bond_3ad.c: switch MAC_ADDRESS_COMPARE macro for
 compare_ether_addr()
Date: Tue, 31 May 2011 02:10:22 +0100
Message-ID: <1306804222.4277.66.camel@localhost>
References: <20110531004418.GA22937@optiplex.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: aquini@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:36752 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab1EaBMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2011 21:12:17 -0400
In-Reply-To: <20110531004418.GA22937@optiplex.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-30 at 21:44 -0300, Rafael Aquini wrote:
> Converts all uses of MAC_ADDRESS_COMPARE macro to compare_ether_addr() and delete the macro.
[...]

Given all the casts you have to add, this doesn't seem like an
improvement.

How about replacing struct mac_addr with u8[ETH_ALEN] at the same time?
You should also be able to get rid of null_mac_addr and use
is_zero_ether_addr() instead.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

