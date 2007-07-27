From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1]ixgbe: Driver for Intel 82598 based 10GbE PCI Express
 family of adapters
Date: Fri, 27 Jul 2007 09:52:02 -0400
Message-ID: <46A9F882.3000208@garzik.org>
References: <20070726200105.27129.18979.stgit@localhost.localdomain> <20070726200841.27129.76915.stgit@localhost.localdomain> <46A91EA5.9060005@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org, auke-jan.h.kok@intel.com,
	hch@infradead.org, nhorman@tuxdriver.com, inaky@linux.intel.com,
	mb@bu3sch.de, john.ronciak@intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57851 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758919AbXG0NwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 09:52:10 -0400
In-Reply-To: <46A91EA5.9060005@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Using module parameter for per device settings is bad idea.
> Please extend existing interfaces like ethtool, etc rather than committing
> to a bad inflexible API.


I agreed with Stephen's comments here.

In general, net driver policy is to use ethtool (per-interface 
granularity) rather than module options.

	Jeff


