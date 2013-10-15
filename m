From: Damian Pietras <damianp@daper.net>
Subject: Re: "xfrm: Fix the gc threshold value for ipv4" broke my IPSec connections
Date: Wed, 16 Oct 2013 00:15:01 +0200
Message-ID: <525DBE65.1070707@daper.net>
References: <525DA855.1010905@daper.net> <1381870957.2045.73.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isp1.vx1.pl ([188.165.119.169]:49116 "EHLO isp1.vx1.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759601Ab3JOWPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 18:15:04 -0400
In-Reply-To: <1381870957.2045.73.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.10.2013 23:02, Eric Dumazet wrote:
>> 703fb94ec58e0e8769380c2877a8a34aeb5b6c97
>> xfrm: Fix the gc threshold value for ipv4
>>
>> Reverting it on 3.10.15 fixes my issue. This seems to be there from 3.7
>> and I don't really believe such simple case stayed broken for so long.
>> Em I missing something or there is really a bug?
>>
>> If smeone is interested in details of this configuration and commands
>> I'm running, just let me know. This was reproduced with few VMs under XEN.
>>
> 
> It looks like you need to tune /proc/sys/net/ipv4/xfrm4_gc_thresh to a
> sensible value given your workload.
> 
> try :
> 
> echo 65536 >/proc/sys/net/ipv4/xfrm4_gc_thresh
> 
> Presumably the 1024 default is really too small...

Now it's working in my test setup, I'm changing it on the production
boxes, thanks!


-- 
Damian Pietras
