From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 30462] New: High cpu usage when someone sends
 many ipv6 udp packages
Date: Fri, 04 Mar 2011 17:21:57 -0800 (PST)
Message-ID: <20110304.172157.48483962.davem@davemloft.net>
References: <bug-30462-10286@https.bugzilla.kernel.org/>
	<20110304171506.0e27cde1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ernstp@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42174
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752178Ab1CEBVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 20:21:20 -0500
In-Reply-To: <20110304171506.0e27cde1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Fri, 4 Mar 2011 17:15:06 -0800

>> The following ipv6 related changes were introduced between -rc2 and -rc3 that I
>> can see. The "Revert 'administrative down' address handling changes." looked
>> big...
>>       ipv6: Always clone offlink routes.
>>       ipv6: Revert 'administrative down' address handling changes.

Can we narrow it down to which of those two changes introduced the
regression?

We have another issue, still open, which is caused by the first
change, so maybe try reverting that one first.

Thanks.
