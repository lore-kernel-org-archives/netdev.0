From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 21:14:02 +0000
Message-ID: <1289855642.2586.38.camel@bwh-desktop>
References: <4CE18CEA.5080502@garzik.org>
	 <1289852326.2586.32.camel@bwh-desktop>  <20101115124428.7b857ccb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59396 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933849Ab0KOVOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 16:14:05 -0500
In-Reply-To: <20101115124428.7b857ccb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-15 at 12:44 -0800, Stephen Hemminger wrote:
[...]
> My views are simple:
> 
> Ethtool needs to be an extension of existing netlink API for interfaces.
>   - handles multiple values per transaction
>   - extensible
[...]

Are you suggesting to send and receive the existing ethtool command and
result structures (with some wrapping) through netlink?  Or some larger
change to the API?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

