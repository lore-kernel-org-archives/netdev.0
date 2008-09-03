From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 40/52] sfc: Rework efx_set_multicast_hash()
Date: Wed, 03 Sep 2008 09:54:51 -0400
Message-ID: <48BE972B.4060503@pobox.com>
References: <20080901111621.GT7908@solarflare.com> <20080901114911.GH7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43463 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752264AbYICNyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 09:54:55 -0400
In-Reply-To: <20080901114911.GH7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> When !port_enabled, defer the write to reconfigure_mac_wrapper.
> 
> Whilst here, simplify the logic now that efx_start_port() always calls
> efx_reconfigure_port().
> 
> From: Steve Hodgson <shodgson@solarflare.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c |   28 +++++++++++++++++-----------
>  1 file changed, 17 insertions(+), 11 deletions(-)

applied patches 1-40

please resend patches 41- because a few did not arrive here


