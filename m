From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Wed, 12 Nov 2008 17:06:33 +0100
Message-ID: <491AFF09.8070907@linux.intel.com>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:60462 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750986AbYKLQGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 11:06:24 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As a general comment on the patch series I'm still a little sceptical
the time stamp offset method is a good idea. Since it tries to approximate
several unsynchronized clocks the result will always be of a little poor
quality, which will likely lead to problems sooner or later (or rather
require ugly workarounds in the user).

I think it would be better to just bite the bullet and add new fields
for this to the skbs. Hardware timestamps are useful enough to justify
this.

-Andi

