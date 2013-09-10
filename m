From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v3.2.y] inetpeer: Invalidate the inetpeer tree along
 with the routing cache
Date: Tue, 10 Sep 2013 14:53:34 -0400 (EDT)
Message-ID: <20130910.145334.1669114772684195996.davem@davemloft.net>
References: <5213A8BB.5070309@canonical.com>
	<1377986658.21578.5.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	linux-kernel@vger.kernel.org, joseph.salisbury@canonical.com,
	steffen.klassert@secunet.com, edumazet@google.com
To: ben@decadent.org.uk
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1377986658.21578.5.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 31 Aug 2013 23:04:18 +0100

> On Tue, 2013-08-20 at 13:34 -0400, Joseph Salisbury wrote:
>> Hello,
>> 
>> Please consider including mainline commit 5faa5df in the next v3.2.y
>> release.  It was included in the mainline tree as of v3.3-rc7.  It has
>> been tested and confirmed to resolve
>> http://bugs.launchpad.net/bugs/1205741 .
>> 
>> 
>> commit 5faa5df1fa2024bd750089ff21dcc4191798263d
>> Author: Steffen Klassert <steffen.klassert@secunet.com>
>> Date:   Tue Mar 6 21:20:26 2012 +0000
>> 
>>     inetpeer: Invalidate the inetpeer tree along with the routing cache
>> 
>> 
>> Also note that commit 5faa5df introduced a race condition that is fixed
>> by mainline commit 55432d2, so that commit would also be required:
>> 
>> commit 55432d2b543a4b6dfae54f5c432a566877a85d90
>> Author: Eric Dumazet <edumazet@google.com>
>> Date:   Tue Jun 5 03:00:18 2012 +0000
>> 
>>     inetpeer: fix a race in inetpeer_gc_worker()
> 
> David, could you ack/nak these for 3.2 (maybe 3.0 as well?).

I'm queueing these two patches up for 3.2 only, the
inetpeer/metrics-cache situation in 3.0 has so many deeper problems
than can be reasonably dealt with using backports.  Just look at the
layout differences of struct inetpeer between 3.0 and 3.2, and the
reasons for that, for the tip of the iceberg.
