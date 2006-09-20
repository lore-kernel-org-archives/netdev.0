From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: Re: [PATCH 08/23] e1000: add multicast stats counters
Date: Wed, 20 Sep 2006 09:38:54 -0700
Message-ID: <F3EE2A9EB4576F40AFE238EC0AC04BC5091F8526@orsmsx402.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33289 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1751672AbWITQjU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 12:39:20 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>, "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> +	{ "rx_broadcast", E1000_STAT(stats.bprc) },
>> +	{ "tx_broadcast", E1000_STAT(stats.bptc) },
>> +	{ "rx_multicast", E1000_STAT(stats.mprc) },
>> +	{ "tx_multicast", E1000_STAT(stats.mptc) },
>>  	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
>>  	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
>>  	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
>
>NAK -- you also need to remove the standard net stats, which are 
>exported elsewhere

Jeff, can you please explain the reason for this NAK a little more?
Neither Auke nor I understand why you rejected the patch.

This patch just adds the display of a few more stats in Ethtool.  It
doesn't affect any other counters, and is really just a convenience
feature.  I added this to the driver because of a customer request.

Thank you in advance for edifying us.

-Mitch

