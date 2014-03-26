From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 21:04:52 +0000
Message-ID: <87ha6k7jt7.fsf@sable.mobileactivedefense.com>
References: <1395798147.12610.196.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E9790@AcuExch.aculab.com>
	<87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:54440 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbaCZVFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 17:05:07 -0400
In-Reply-To: <87y4zw7ngi.fsf@sable.mobileactivedefense.com> (Rainer Weikusat's
	message of "Wed, 26 Mar 2014 19:46:05 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rainer Weikusat <rw@sable> writes:

[...]

> The underlying problem would seem to be that a O_NONBLOCK call might
> actually block forever in case a blocking receiver sits on the lock and
> no data is ever received.

... except that this probably cannot happen because O_NONBLOCK is a file
status flag and not a file descriptor flag.

NB: I've neither tested nor checked this.
