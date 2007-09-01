From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8961] New: BUG triggered by oidentd in netlink
 code
Date: Sun, 02 Sep 2007 00:53:29 +0200
Message-ID: <46D9ED69.7030706@trash.net>
References: <bug-8961-10286@http.bugzilla.kernel.org/> <20070830180842.7c8414fe.akpm@linux-foundation.org> <Pine.LNX.4.64.0708311258520.8423@x2> <20070831123825.GW22067@miggy.org> <46D9957F.4020101@trash.net> <20070901173944.GB3693@miggy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Athanasius <link@miggy.org>, Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-d
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34355 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbXIAWxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 18:53:46 -0400
In-Reply-To: <20070901173944.GB3693@miggy.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Athanasius wrote:
> On Sat, Sep 01, 2007 at 06:38:23PM +0200, Patrick McHardy wrote:
>>
>> You might be able to trigger it without this patch by running
>> "while true; do ss -tn; done" while doing ident queries, but
>> just running the while loop a couple of times in parallel
>> doesn't seem to trigger it here.
> 
>   I went for setting up a dummy listener in inetd, using tcpd, and
> setting hosts.allow to specify myuser@ip.  Then a few while loops
> spamming it with connections using nc.
> 
>   Anyway, on the old kernel that managed to trigger the BUG twice in
> about 30 minutes.  I'm now on 2.6.22.6 plus your patch and coming up on
> an hour (55+ mins) of the same and no sign of the BUG.
> 
>   So that looks like fixed to me.  I'll weigh in again if the daily
> logcheck throws up another.


Thanks a lot for testing, I'll send a version for current -rc
upstream tommorrow.

