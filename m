From: sunny12 <johanhen@yahoo.com>
Subject: Re: tg3 driver timeout problems
Date: Thu, 14 Sep 2006 14:24:08 -0700 (PDT)
Message-ID: <6315074.post@talk.nabble.com>
References: <6252031.post@talk.nabble.com> <1158005660.5436.9.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.nabble.com ([72.21.53.35]:17625 "EHLO talk.nabble.com")
	by vger.kernel.org with ESMTP id S1751189AbWINVYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 17:24:10 -0400
Received: from [72.21.53.38] (helo=jubjub.nabble.com)
	by talk.nabble.com with esmtp (Exim 4.50)
	id 1GNygq-00019y-IJ
	for netdev@vger.kernel.org; Thu, 14 Sep 2006 14:24:08 -0700
To: netdev@vger.kernel.org
In-Reply-To: <1158005660.5436.9.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Thanks a lot Michael, it seems to have resolved the issue, at least we were
not able to reproduce it again
after changing this flag. I will update this thread if the issue reoccurs.



Michael Chan wrote:
> 
> On Mon, 2006-09-11 at 11:18 -0700, sunny12 wrote:
> 
>> A restart of the network using /etc/init.d/network restart does the trick
>> and the device works again.
>> I dont think this is related to the TSO problem reported earlier because
>> I
>> believe its disabled by default.
>> 
> TSO may be on by default on eth0 where you have a 5721.  Check with
> ethtool -k eth0.  Turn it off if it is on by doing ethtool -K eth0 tso
> off.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

-- 
View this message in context: http://www.nabble.com/tg3-driver-timeout-problems-tf2254084.html#a6315074
Sent from the netdev forum at Nabble.com.

