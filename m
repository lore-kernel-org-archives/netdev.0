From: Dave Jones <davej@redhat.com>
Subject: Re: ax25_recvmsg lockup
Date: Sat, 3 Aug 2013 20:25:20 -0400
Message-ID: <20130804002520.GA10206@redhat.com>
References: <20130617142803.GB16732@redhat.com>
 <20130803.134604.508965748339486186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192Ab3HDAZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 20:25:29 -0400
Content-Disposition: inline
In-Reply-To: <20130803.134604.508965748339486186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 03, 2013 at 01:46:04PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Mon, 17 Jun 2013 10:28:03 -0400
 > 
 > > With the right arguments from userspace, reading from an ax25 socket
 > > can spend long enough in the kernel that it triggers the softlockup
 > > detector.  I hit a bunch of these traces in a trinity run that I
 > > left running over the weekend.
 > 
 > I looked at this a bunch of times and am still mystified how this
 > can happen.
 > 
 > It should be simple to diagnose since I doubt there is any real
 > AX25 traffic going to these sockets.
 > 
 > Any chance you can figure out what the arguments are that cause
 > this problem?  That'll probably help a lot, thanks!

I've not seen it in a while, I'll have a think about what I can
do to try and provoke it more reliably on Monday.

	Dave
