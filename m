From: David Miller <davem@davemloft.net>
Subject: Re: ax25_recvmsg lockup
Date: Sat, 03 Aug 2013 13:46:04 -0700 (PDT)
Message-ID: <20130803.134604.508965748339486186.davem@davemloft.net>
References: <20130617142803.GB16732@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979Ab3HCUqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 16:46:05 -0400
In-Reply-To: <20130617142803.GB16732@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 17 Jun 2013 10:28:03 -0400

> With the right arguments from userspace, reading from an ax25 socket
> can spend long enough in the kernel that it triggers the softlockup
> detector.  I hit a bunch of these traces in a trinity run that I
> left running over the weekend.

I looked at this a bunch of times and am still mystified how this
can happen.

It should be simple to diagnose since I doubt there is any real
AX25 traffic going to these sockets.

Any chance you can figure out what the arguments are that cause
this problem?  That'll probably help a lot, thanks!
