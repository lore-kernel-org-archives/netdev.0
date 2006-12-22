From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Fri, 22 Dec 2006 08:42:09 +0100
Message-ID: <20061222074209.GA2148@ff.dom.local>
References: <45889C53.8000307@candelatech.com> <20061222071308.GA1791@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:49243 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945959AbWLVHlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 02:41:01 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <20061222071308.GA1791@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 22, 2006 at 08:13:08AM +0100, Jarek Poplawski wrote:
> On 20-12-2006 03:13, Ben Greear wrote:
> > This is from 2.6.18.2 kernel with my patch set.  The MAC-VLANs are in 
> > active use.
> >  From the backtrace, I am thinking this might be a generic problem, 
> > however.
> > 
> > Any ideas about what this could be?  It seems to be reproducible every 
> > day or
...
> If it doesn't help, I hope lockdep will be more
> precise when you'll upgrade to 2.6.19 or higher.

... or when you enable lockdep in 2.6.18 (I've
forgotten it's there alredy!).

Jarek P.
