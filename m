From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fs_enet: Update for API changes
Date: Wed, 17 Oct 2007 20:21:22 -0400
Message-ID: <4716A702.7050907@pobox.com>
References: <20071017174243.GA4462@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49913 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761149AbXJRAVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 20:21:25 -0400
In-Reply-To: <20071017174243.GA4462@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Wood wrote:
> This driver was recently broken by several changes for which this
> driver was not (or was improperly) updated:
> 
> 1. SET_MODULE_OWNER() was removed.
> 2. netif_napi_add() was only being called when building with
> the old CPM binding.
> 3. The received/budget test was backwards.
> 4. to_net_dev() was wrong -- the device struct embedded in
> the net_device struct is not the same as the of_platform
> device in the private struct.
> 5. napi_disable/napi_enable was being called even when napi
> was not being used.
> 
> These changes have been fixed, and napi is now on by default.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>

applied


