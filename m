From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 09/13] bnx2x: add pri_map module parameter
Date: Thu, 10 Nov 2011 17:39:47 +0000
Message-ID: <1320946787.2851.2.camel@bwh-desktop>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
	 <1320938054-31288-10-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37814 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab1KJRjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 12:39:55 -0500
In-Reply-To: <1320938054-31288-10-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-10 at 17:14 +0200, Dmitry Kravkov wrote:
> From: Ariel Elior <ariele@broadcom.com>
> 
> The optional parameter pri_map is used to map the
> skb->priority to a Class Of Service (CoS) in the HW.
> This 32 bit parameter is evaluated by the  driver as 8
> values of 4 bits each. Each nibble sets the desired
> HW queue number for that priority.
[...]

You should implement ndo_tc_setup instead of adding a driver-specific
parameter (that should be per-device anyway).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
