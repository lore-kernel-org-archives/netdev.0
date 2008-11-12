From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 02/13] extended semantic of sk_buff::tstamp: lowest
 bit marks hardware time stamps
Date: Wed, 12 Nov 2008 02:09:14 -0800 (PST)
Message-ID: <20081112.020914.109939543.davem@davemloft.net>
References: <1226415407.31699.1.camel@ecld0pohly>
	<491A88AB.8070006@cosmosbay.com>
	<1226477344.31699.44.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, opurdila@ixiacom.com,
	shemminger@vyatta.com, netdev@axxeo.de, ak@linux.intel.com,
	john.ronciak@intel.com, oliver@hartkopp.net
To: patrick.ohly@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39534
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751700AbYKLKJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:09:14 -0500
In-Reply-To: <1226477344.31699.44.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Ohly <patrick.ohly@intel.com>
Date: Wed, 12 Nov 2008 09:09:04 +0100

> On Wed, 2008-11-12 at 07:41 +0000, Eric Dumazet wrote:
> > Please use ktime_t instead of "union ktime"
> 
> Are you sure? 
> 
> include/linux/ktime.h says
>         typedef union ktime ktime_t;            /* Kill this */
> and the CodingStyle also seems to be against it.
> 
> I thought it would be good to avoid using the typedef in new code, but
> if consistency with the existing code is preferred, then I'll change it.

Well you then go ahead and cast return values to "ktime_t"
so this code is not even being consistent about the choice.
