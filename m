From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 08/23] e1000: add multicast stats counters
Date: Wed, 20 Sep 2006 15:22:11 -0400
Message-ID: <451194E3.3070107@pobox.com>
References: <F3EE2A9EB4576F40AFE238EC0AC04BC5091F8526@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:8680 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932270AbWITTWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 15:22:15 -0400
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
In-Reply-To: <F3EE2A9EB4576F40AFE238EC0AC04BC5091F8526@orsmsx402.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Williams, Mitch A wrote:
>>> +	{ "rx_broadcast", E1000_STAT(stats.bprc) },
>>> +	{ "tx_broadcast", E1000_STAT(stats.bptc) },
>>> +	{ "rx_multicast", E1000_STAT(stats.mprc) },
>>> +	{ "tx_multicast", E1000_STAT(stats.mptc) },
>>>  	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
>>>  	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
>>>  	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
>> NAK -- you also need to remove the standard net stats, which are 
>> exported elsewhere
> 
> Jeff, can you please explain the reason for this NAK a little more?
> Neither Auke nor I understand why you rejected the patch.
> 
> This patch just adds the display of a few more stats in Ethtool.  It
> doesn't affect any other counters, and is really just a convenience
> feature.  I added this to the driver because of a customer request.

Adding those stats is fine.  You guys just need to remove the existing 
mess first.

	Jeff



