From: David Miller <davem@davemloft.net>
Subject: Re: [0/2] Fix problems with with IFLA_VF_PORTS (v2)
Date: Thu, 24 Apr 2014 13:53:23 -0400 (EDT)
Message-ID: <20140424.135323.2147922052612934860.davem@davemloft.net>
References: <1398298956-13084-1-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, neepatel@cisco.com,
	benve@cisco.com, ben@decadent.org.uk, govindarajulu90@gmail.com,
	gregory.v.rose@intel.com
To: david@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758829AbaDXRxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:53:25 -0400
In-Reply-To: <1398298956-13084-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Gibson <david@gibson.dropbear.id.au>
Date: Thu, 24 Apr 2014 10:22:34 +1000

> I've had a customer encounter a problem with getifaddrs(3) freezing up
> on a system with a Cisco enic device.
> 
> I've discovered that the problem is caused by an enic device with a
> large number of SR-IOV virtual functions overflowing the normal sized
> packet buffer for netlink, leading to interfaces not being reported
> from an RTM_GETLINK request.
> 
> The first patch here just makes the problem easier to locate if it
> occurs again in a different way, by adding a WARN_ON() when we run out
> of room in a netlink packet in this manner.
> 
> The second patch actually fixes the problem, by only reporting
> IFLA_VF_PORTS information when the RTEXT_FILTER_VF flag is specified.
> 
> v2: Corrected some CodingStyle problems

Series applied to 'net' and queued up for -stable.

Thanks!
