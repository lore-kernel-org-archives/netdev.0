From: Tejun Heo <tj@kernel.org>
Subject: Re: Linux 3.0 release
Date: Sat, 23 Jul 2011 04:30:23 +0200
Message-ID: <20110723023023.GC21089@mtj.dyndns.org>
References: <CA+55aFxakA2U+oMJ1T7awTYa+p6xp9N0aCbfrUqgkF7BJ8gnQw@mail.gmail.com>
 <4E29CB5B.4040408@unsolicited.net>
 <CA+55aFy1FnVGH4C_0T8fXwZPUdz5-SCczMwy1K8kydLwTx89RQ@mail.gmail.com>
 <4E29D326.7070403@candelatech.com>
 <20110722133220.0baf2199@nehalam.ftrdhcpuser.net>
 <CA+55aFwX55HhzyPsb5vx-=xkHpWJBH0481ZFWcXnNzH1M6zhdg@mail.gmail.com>
 <20110723022715.GB21089@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	David <david@unsolicited.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f52.google.com ([209.85.161.52]:45635 "EHLO
	mail-fx0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab1GWCa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2011 22:30:28 -0400
Content-Disposition: inline
In-Reply-To: <20110723022715.GB21089@mtj.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 23, 2011 at 04:27:15AM +0200, Tejun Heo wrote:
> While on the topic, we do have some workqueue API problems.  The
> delayed ones are a bit screwy.  e.g. requeueing an already pending
> delayed work item should probably update the timer but it doesn't andp
> we have a bunch of users doing cancel/requeue or using separate timers
> for that.

(after reading the other branch of the thread) Ooh, bingo, this
actually was the issue which triggered the problem reported here. :)

-- 
tejun
