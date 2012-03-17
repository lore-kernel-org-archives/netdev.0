From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net 2/3] net: do not do gso for CHECKSUM_UNNECESSARY in
 netif_needs_gso
Date: Sat, 17 Mar 2012 18:41:56 +0000
Message-ID: <1332009716.3022.243.camel@deadeye>
References: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Yi Zou <yi.zou@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:22729 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752268Ab2CQSmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 14:42:03 -0400
In-Reply-To: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-03-17 at 02:08 -0700, Jeff Kirsher wrote:
> From: Yi Zou <yi.zou@intel.com>
> 
> This is related to fixing the bug of dropping FCoE frames when disabling tx ip
> checksum by 'ethtool -K ethx tx off'. The FCoE protocol stack driver would
> use CHECKSUM_UNNECESSARY on tx path instead of CHECKSUM_PARTIAL (as indicated in
> the 2/2 of this series). To do so, netif_needs_gso() has to be changed here to
> not do gso for both CHECKSUM_PARTIAL and CHECKSUM_UNNECESSARY.
[...]

This should also be documented as valid in include/linux/skbuff.h,
though I don't think the fix should be held up for that.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
