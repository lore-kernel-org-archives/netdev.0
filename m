From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug 10071] kernel hang in inet_init (PREEMPT_RCU problem)
Date: Thu, 28 Feb 2008 22:34:57 +0100
Message-ID: <20080228213457.GA2770@ami.dom.local>
References: <bug-10071-11547@http.bugzilla.kernel.org/> <20080228205303.261D311D108@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yannick Dirou <yannick.dirou@axetic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:60277 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877AbYB1V34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:29:56 -0500
Received: by nf-out-0910.google.com with SMTP id g13so2032166nfb.21
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 13:29:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080228205303.261D311D108@picon.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2008 at 12:53:03PM -0800, bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=10071
...
> ------- Comment #17 from yannick.dirou@axetic.com  2008-02-28 12:53 -------
> bingo with classic rcu

Congratulations Yannick!

So, it seems mainly RCU vs. timer(?) problem. I send CC of this message
to RCU author, linux-kernel and netdev lists.

I'm not sure how much time you could/will to offer for this debugging.
Anyway, if it's possible I think it would be interesting to check with
CONFIG_PREEMPT_RCU = y again, but CONFIG_HOTPLUG_CPU = n ("Processor
type and features --> Support for suspend on SMP and ...") in the
meantime.

Many thanks,
Jarek P.


> [    0.770854] NET: Registered protocol family 2
> [    0.770868] 4294668327 net/ipv4/af_inet.c 1387
> [    0.770884] 4294668327 net/ipv4/af_inet.c 1390
> [    0.770888] 4294668327 net/ipv4/af_inet.c 1393
> [    0.770891] 4294668327 net/ipv4/af_inet.c 1402
> [    0.770893] 4294668327 net/ipv4/af_inet.c 1407
> [    0.773078] 0 4294668328l
> [    0.774036] 0 4294668329l
> [    0.775037] 0 4294668330l
> [    0.775040] 4294668330 net/ipv4/af_inet.c 1419
> [    0.775077] 4294668330 net/ipv4/af_inet.c 1426
> [    0.775077] 4294668330 net/ipv4/route.c 2998
> [    0.775077] 4294668330 net/ipv4/route.c 3009
> [    0.775077] 4294668330 net/ipv4/route.c 3016
> [    0.775077] IP route cache hash table entries: 32768 (order: 5, 131072
> bytes)
> [    0.775077] 4294668330 net/ipv4/route.c 3027
> [    0.775492] TCP established hash table entries: 131072 (order: 8, 1048576
> bytes)
> [    0.776318] TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
> [    0.785670] TCP: Hash tables configured (established 131072 bind 65536)
> [    0.785715] TCP reno registered
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
> You are the assignee for the bug, or are watching the assignee.
