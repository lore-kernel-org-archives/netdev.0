From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Wed, 27 Jun 2007 14:10:13 +0200
Message-ID: <20070627121013.GB3762@ff.dom.local>
References: <20070627114521.GA3762@ff.dom.local> <46824D88.1090300@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:48923 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754358AbXF0MCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 08:02:04 -0400
Content-Disposition: inline
In-Reply-To: <46824D88.1090300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 27, 2007 at 01:44:08PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> >On 25-06-2007 11:28, Patrick McHardy wrote:
> >...
> >  
> >>It is. This patch I had originally planned for 2.6.23 switches HTB
> >>to the generic estimator, which shouldn't suffer from this.
> >>    
> >
> >BTW, maybe I look at this too short, but is this del_timer()
> >in gen_kill_estimator() enough? I cannot see nothing against
> >a timer just running and doing mod_timer() again...
> 
> Yes, but nothing bad can happen, the timer will find an empty
> list and do nothing. It would make more sense to check for
> an empty list before restarting the timer though.
> 
> 
> Could you send a patch for that?
> 

Probably I could, but it's your idea!

I look at this just now, and maybe it's enough for asking,
but definitely not enough for patch. I'll try to check this
more in the evening, so I could send something tomorrow.

So if it's not only about kindness, feel free to do it
sooner and I've no doubts  - better.

Thanks for so instant reply!
Jarek P.
