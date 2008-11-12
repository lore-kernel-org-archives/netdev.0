From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: [RFC PATCH 04/13] net: implement generic SOF_TIMESTAMPING_TX_*
	support
Date: Wed, 12 Nov 2008 09:38:14 +0100
Message-ID: <1226479094.31699.56.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <1226415417.31699.3.camel@ecld0pohly>
	 <200811120115.09330.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31367 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753055AbYKLIiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 03:38:18 -0500
In-Reply-To: <200811120115.09330.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-11-11 at 23:15 +0000, Octavian Purdila wrote:
> I think the addition of the following bits will be of use to applications: 
> 
>         serr = SKB_EXT_ERR(skb);
>         serr->ee.ee_origin = SO_EE_ORIGIN_TXTSTAMP;
>         serr->ee.ee_mac = skb->mac.raw - skb->data;
>         serr->ee.ee_network = skb->nh.raw - skb->data;
>         serr->ee.ee_transport = skb->h.raw - skb->data;
> 
> For example, for UDP PTP we don't have to manually skip the ethernet (and take 
> into account VLANs) and IP headers.

Yes, that would be useful. Will add it.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

