From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Thu, 13 Nov 2008 07:15:48 +0100
Message-ID: <491BC614.9050201@hartkopp.net>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com> <491B3B49.7070402@linux.intel.com> <491B42FF.3000407@cosmosbay.com> <491B4BE3.3010104@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:10843 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbYKMGPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 01:15:53 -0500
In-Reply-To: <491B4BE3.3010104@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Eric Dumazet wrote:
>
>> I threw a "crazy idea", that can be changed if necessary, say with a 
>> cookie
>> that identifies the slot in NIC driver structure. O(1) lookup if 
>> really needed.
>
> I think "crazy" describes it well because it would be a lot of dubious
> and likely not performing well effort just to save 8 bytes.

Patrick,

one question about a new crazy idea:

If we would tend to add new space in the skb, won't 4 bytes enough then?

A 32 bit value gives a nsec resolution of 4.294967296 seconds or +/- 
2.147483648 seconds.

If we make a 'full qualified' 64 bit sys-timestamp available anyway, the 
new 32 bit value could be used as an offest (or it could be given to the 
userspace directly) to calculate the hw timestamp within the 
sys-timestamp context, right?

Regards,
Oliver

