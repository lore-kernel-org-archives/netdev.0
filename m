From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Tue, 3 Jan 2012 21:05:28 +0000
Message-ID: <1325624728.2832.12.camel@bwh-desktop>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Bruce Allan <bruce.w.allan@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30244 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752755Ab2ACVFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 16:05:32 -0500
In-Reply-To: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-03 at 11:19 -0800, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Enable RPS by default.  Disallow jumbo frames when both receive checksum
> and receive hashing are enabled because the hardware cannot do both IP
> payload checksum (enabled when receive checksum is enabled when using
> packet split which is used for jumbo frames) and provide RSS hash at the
> same time.
[...]

This doesn't seem to have much to do with RPS.  RPS can use a hardware
hash but doesn't require it.

You should also implement the ethtool command to query flow hashing
behaviour (ETHTOOL_GRXFH command, get_rxnfc operation).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
