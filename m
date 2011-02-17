From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 29252] New: IPv6 doesn't work in a kvm guest.
Date: Thu, 17 Feb 2011 14:32:37 -0800 (PST)
Message-ID: <20110217.143237.245412709.davem@davemloft.net>
References: <bug-29252-10286@https.bugzilla.kernel.org/>
	<20110217142517.b9919481.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, slash@ac.auone-net.jp
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45167
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751170Ab1BQWcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:32:01 -0500
In-Reply-To: <20110217142517.b9919481.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 17 Feb 2011 14:25:17 -0800

>> https://bugzilla.kernel.org/show_bug.cgi?id=29252
 ...
>> apt-get and ping6 don't work in a kvm guest. It appears that neighbor discovery
>> is not working. I'm using tap, virtio-net and vhost. I did bisect and results
>> is
>> 
>> d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4 is the first bad commit
>> commit d80bc0fd262ef840ed4e82593ad6416fa1ba3fc4
>> Author: David S. Miller <davem@davemloft.net>
>> Date:   Mon Jan 24 16:01:58 2011 -0800
>> 
>>     ipv6: Always clone offlink routes.
>> 
>>     Do not handle PMTU vs. route lookup creation any differently
>>     wrt. offlink routes, always clone them.
>> 
>>     Reported-by: PK <runningdoglackey@yahoo.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
>> 
>> :040000 040000
>> c4a34e9e36bd8cc81e898738f2d4344f6647d472f0fcd4b093ec22784798f3951203391f4567b278
>> M      net
>> 
>> reverting this commit for guest kernel fixes the probrem.

Thanks for the report, I'll look into this.
