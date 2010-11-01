From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3] offloading: Make scatter/gather more tolerant of
 vlans.
Date: Mon, 01 Nov 2010 20:06:29 +0000
Message-ID: <1288641989.2231.3.camel@achroite.uk.solarflarecom.com>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19860 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab0KAUGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 16:06:32 -0400
In-Reply-To: <1288390495-28923-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-29 at 15:14 -0700, Jesse Gross wrote:
> When checking if it is necessary to linearize a packet, we currently
> use vlan_features if the packet contains either an in-band or out-
> of-band vlan tag.  However, in-band tags aren't special in any way
> for scatter/gather since they are part of the packet buffer and are
> simply more data to DMA.  Therefore, only use vlan_features for out-
> of-band tags, which could potentially have some interaction with
> scatter/gather.
> 
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

