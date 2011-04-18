From: Dave Jones <davej@redhat.com>
Subject: Re: ip_rt_bug questions.
Date: Mon, 18 Apr 2011 17:59:23 -0400
Message-ID: <20110418215922.GA17818@redhat.com>
References: <20110418214809.GA17443@redhat.com>
 <20110418.144909.52209035.davem@davemloft.net>
 <20110418.145023.13728986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab1DRV70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 17:59:26 -0400
Content-Disposition: inline
In-Reply-To: <20110418.145023.13728986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 02:50:23PM -0700, David Miller wrote:
 
 > >> ip_rt_bug: 0.0.0.0 -> 255.255.255.255, ?
 > >> 
 > > It's a very serious issue, it means we used an input route for
 > > packet output.
 > > 
 > > Kernel version and what you were doing to trigger this?

current HEAD from Linus' tree.
It fell out twice so far this afternoon from my system call fuzzer.

 > BTW, if you could modify this thing to spit out a stack
 > trace (probably by using WARN_ON() or similar) that will
 > probably show us where the bug is coming from.

Ok, I'll add that, and see if I can reproduce it again.

	Dave

