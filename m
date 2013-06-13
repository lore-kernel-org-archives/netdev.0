From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH net-next] cxgb4: Do not set net_device::dev_id to
 VI index
Date: Thu, 13 Jun 2013 01:24:36 -0700 (PDT)
Message-ID: <20130613.012436.175444386183812706.davem@davemloft.net>
References: <1370882053.1933.13.camel@bwh-desktop.uk.level5networks.com>
	<CBA48B605613B640864883107238931C054E67@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	Narendra_K@Dell.com
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758338Ab3FMIYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 04:24:37 -0400
In-Reply-To: <CBA48B605613B640864883107238931C054E67@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitrios Michailidis <dm@chelsio.com>
Date: Thu, 13 Jun 2013 06:15:43 +0000

> Ben Hutchings wrote:
>> 
>> net_device::dev_id should not be used merely to indicate a VI index,
>> as it affects the way the local part of IPv6 addresses is normally
>> generated.
>> 
>> This field was intended for use where multiple devices may share a
>> single assigned MAC address and need to have different IPv6 addresses.
>> T4 VIs each have their own MAC address.
>> 
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Acked-by: Dimitris Michailidis <dm@chelsio.com>

Applied, thanks.
