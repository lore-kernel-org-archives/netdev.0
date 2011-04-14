From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sfc: make function tables const
Date: Thu, 14 Apr 2011 17:37:18 +0100
Message-ID: <1302799038.2853.5.camel@bwh-desktop>
References: <20110414085012.3e45d7b4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Steve Hodgson <shodgson@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21745 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab1DNQhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 12:37:22 -0400
In-Reply-To: <20110414085012.3e45d7b4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-14 at 08:50 -0700, Stephen Hemminger wrote:
> The phy, mac, and board information structures should be const.

efx_nic_type actually holds information and function pointers about
different generations of the controller, not different boards.

> Since tables contain function pointer this improves security
> (at least theoretically).
> 
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

