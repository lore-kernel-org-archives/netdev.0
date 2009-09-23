From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: fanotify as syscalls
Date: Wed, 23 Sep 2009 17:58:50 -0400
Message-ID: <20090923215850.GA30818@infradead.org>
References: <20090912094110.GB24709@ioremap.net> <200909221731.34717.agruen@suse.de> <alpine.DEB.2.00.0909220836200.10460@makko.or.mcafeemobile.com> <200909230939.34003.tvrtko.ursulin@sophos.com> <20090923112018.GA2946@infradead.org> <alpine.DEB.2.00.0909230827100.21515@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "hch@infradead.org" <hch@infradead.org>,
	Tvrtko Ursulin <tvrtko.ursulin@sophos.com>,
	Andreas Gruenbacher <agruen@suse.de>,
	Jamie Lokier <jamie@shareable.org>,
	Eric Paris <eparis@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"alan@linux.intel.com" <alan@linux.intel.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:52215 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbZIWV7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 17:59:02 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0909230827100.21515@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2009 at 08:35:18AM -0700, Davide Libenzi wrote:
> The fear is that this becomes a trojan horse (no pun intended) for more 
> and more hooks and "stuff", driven by we-really-need-this-too and 
> we-really-need-that-too. And once something it's in, it's harder to say no, 
> under the pressure of offering a "limited solution".
> This ws the reason I threw the syscall tracing thing in, so they have a 
> low level generic hook, and they cam knock themselves out in their module 
> (might need a few exports, but that's about it).

Replacing idiotify with a saner interface is a good goal.  I just don't
think we should take the stakes of the snake oil industry too serious in
it.

