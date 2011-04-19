From: Dave Jones <davej@redhat.com>
Subject: Re: ip_rt_bug questions.
Date: Tue, 19 Apr 2011 14:13:22 -0400
Message-ID: <20110419181322.GA2034@redhat.com>
References: <20110418.144909.52209035.davem@davemloft.net>
 <20110418.145023.13728986.davem@davemloft.net>
 <20110418215922.GA17818@redhat.com>
 <20110418.220419.226797064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752663Ab1DSSN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 14:13:26 -0400
Content-Disposition: inline
In-Reply-To: <20110418.220419.226797064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 18, 2011 at 10:04:19PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Mon, 18 Apr 2011 17:59:23 -0400
 > 
 > > On Mon, Apr 18, 2011 at 02:50:23PM -0700, David Miller wrote:
 > >  
 > >  > BTW, if you could modify this thing to spit out a stack
 > >  > trace (probably by using WARN_ON() or similar) that will
 > >  > probably show us where the bug is coming from.
 > > 
 > > Ok, I'll add that, and see if I can reproduce it again.
 > 
 > Thanks a lot Dave.

So I hit that twice in the same hour yesterday, but haven't been
able to reproduce it since.  My fuzzer must have been dependant
upon something I can't influence (memory contents perhaps, I pass
around random pointers).

I'll keep the WARN_ON in there in case I do stumble across it again.

	Dave
