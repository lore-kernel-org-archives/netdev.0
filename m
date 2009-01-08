From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Thu, 08 Jan 2009 12:40:46 -0800
Message-ID: <1231447246.1739.61.camel@localhost>
References: <1231446610.3893.17.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4073 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbZAHUlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 15:41:04 -0500
In-Reply-To: <1231446610.3893.17.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-08 at 20:30 +0000, Ben Hutchings wrote:
> Following the removal of the unused struct net_device * parameter from
> the NAPI functions named *netif_rx_* in commit 908a7a1, they are
> exactly equivalent to the corresponding *napi_* functions and are
> therefore redundant.

[]

> I revisited this to update the out-of-tree version of the sfc driver.
> This makes the *netif_rx_* functions equivalent to the corresponding
> *napi_* functions.  So let's finish the job.  This is another search-
> and-replace, mostly compile-tested.

napi was just new-api.
Why persist what seems a poor naming choice?


