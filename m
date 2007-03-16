From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/5] AF_RXRPC: Make it possible to merely try to cancel timers and delayed work [try #2]
Date: Fri, 16 Mar 2007 14:22:09 +0000
Message-ID: <25539.1174054929@redhat.com>
References: <20070316150705.0b2fbeb0@lxorguk.ukuu.org.uk>  <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125026.3740.56876.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965026AbXCPOW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 10:22:28 -0400
In-Reply-To: <20070316150705.0b2fbeb0@lxorguk.ukuu.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > +static inline int try_to_cancel_delayed_work(struct delayed_work *work)
> > +{
> > +	int ret;
> 
> This expands to a fair bit of code and IMHO isn't an inline candidate.

Then why is cancel_delayed_work() inline?  It's very similar in terms of
expansion.

And it's not a fair bit of code.  try_to_cancel_delayed_work() is out of line,
and work_release() is just clear_bit() in disguise.

David
