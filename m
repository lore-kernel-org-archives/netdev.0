From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp compilation failed due to lack of
 sctp_local_addr_free
Date: Thu, 26 May 2011 15:58:02 -0400 (EDT)
Message-ID: <20110526.155802.1831835970562812358.davem@davemloft.net>
References: <837A992BD1360242AE0C50C6BCB069C18415C8@orsmsx003.amr.corp.intel.com>
	<20110526.144416.252997714470172705.davem@davemloft.net>
	<1306436821.28745.4.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org,
	difrost.kernel@gmail.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755475Ab1EZT6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 15:58:10 -0400
In-Reply-To: <1306436821.28745.4.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 26 May 2011 22:07:01 +0300

> On Thu, 2011-05-26 at 11:44 -0700, David Miller wrote:
>> From: "Allan, Bruce W" <bruce.w.allan@intel.com>
>> Date: Thu, 26 May 2011 11:40:34 -0700
>> 
>> >>-----Original Message-----
>> >>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>> >>Behalf Of David Miller
>> >>Sent: Thursday, May 26, 2011 10:39 AM
>> >>To: dmitry@broadcom.com
>> >>Cc: netdev@vger.kernel.org; difrost.kernel@gmail.com
>> >>Subject: Re: [PATCH] sctp compilation failed due to lack of sctp_local_addr_free
>> >>
>> >>
>> >>This has been fixed for days.
>> > 
>> > Fixed in net-2.6, yes, but not yet in net-next-2.6
>> 
>> net-next-2.6 is not active and is just a dummy tree for Stephen
>> Rothwell to pull into -next
>> 
>> You should never be referencing or using net-next-2.6 during the
>> merge window when new features changes are not being accepted.
>> Only net-2.6 is active during this time.
>> 
> Hmm, so how similar will be net-2.6 and net-next-2.6 when re-opened?
> You apply a lot of fixes during this time...

When it opens up I just update net-next-2.6 to whatever is in net-2.6
at the time.
